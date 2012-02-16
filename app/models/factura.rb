# == Schema Information
# Schema version: 20110516183603
#
# Table name: comprobantes
#
#  id         :integer         not null, primary key
#  cliente_id :integer
#  type       :string(255)
#  fecha      :date
#  importe    :decimal(, )
#  numero     :integer
#  fechavto   :date
#  printed_at :date
#  created_at :datetime
#  updated_at :datetime
#
require 'prawn'

class Factura < Comprobante
  scope :no_actualizados, where("updated_at IS NULL" )
  scope :vencidas, where("fechavto < ?", Date.today)
  scope :por_cliente, lambda {|cliente| where(:cliente_id => cliente) }

  def signo
    1
  end

  def total_iva_factura
    detalles.all.sum(&:totalivaitem)
  end

  def isprinted?
    printed_at?
  end
  
  def total_monto_cancelado
    self.creditoafectaciones.all.sum(&:importe) #+ self.facturanotacreditos.all.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.importe - self.total_monto_cancelado
  end

  def sin_deuda?
    total_monto_adeudado == 0
  end

  def con_deuda?
    total_monto_adeudado > 0
  end
   
  #properties for entry 
  def ventas_factura_total(*args)
    entry,referencia = args

    entry.details.build do |dt|
      dt.account_id  = self.cliente.account_id.presence || referencia.account_id      
      dt.description = __method__.to_s.humanize + ' fc' + self.numero.to_s

      dt.credit      = referencia.debita? ? 0 : self.importe
      dt.debit       = referencia.debita? ? self.importe : 0      
    end
  end 
   
  def ventas_factura_subtotal(*args)
    options = args.extract_options! # para permitir flexibilidad a la hora de pasar parametros por hash
    entry,referencia = args
    
    x = detalles.group_by{|detalle| detalle.product.account_id} 

    x.each do |account_id, detalles|
      total = detalles.sum{|detalle| detalle.totalnetoitem} 

      entry.details.build do |dt|
        dt.account_id  = account_id || referencia.account_id
        dt.description = __method__.to_s.humanize + ' fc' + self.numero.to_s

        dt.credit      = referencia.debita? ? 0 : total
        dt.debit       = referencia.debita? ? total : 0      
      end
    end 
    #self.importe - self.total_iva_factura
  end
  
  def ventas_factura_iva(*args)
    entry,referencia = args
    x = detalles.reject{|detalle| detalle.totalivaitem.zero?}.group_by{|detalle| detalle.product.tasaiva.account_id} 

    x.each do |account_id, detalles|
      total = detalles.sum{|detalle| detalle.totalivaitem} 
      # description = detalles.product.tasaiva.
      
      #unless total.zero? 
        entry.details.build do |dt|
          dt.account_id  = account_id.blank? ? referencia.account_id : account_id
          # dt.account_id  = account_id || referencia.account_id
          dt.description = __method__.to_s.humanize + ' fc' + self.numero.to_s
          dt.credit      = referencia.debita? ? 0 : total
          dt.debit       = referencia.debita? ? total : 0      
        end
      #end

    end 
    
    #self.total_iva_factura
  end
  
  def ventas_factura_iibb(*args)
    0.0
  end  
  #end properties for entry
      
  def to_entry
    Entry.new do |entry|
      entry.date_on     = self.fecha
      entry.description = self.cliente.razonsocial.to_s
      entry.exercise_id = self.cliente.company.exercises.where('started_on <= :fecha and finished_on >= :fecha',:fecha => self.fecha).first.try(:id)
      
      # cada referencia es mapeada al asiento
      ref = self.cliente.company.refenciacontables.where('referencename like ?',"ventas_factura_%")
      
      ref.each do |referencia|
        raise "falta metodo #{referencia.referencename}" unless self.respond_to?(referencia.referencename)
        
        next if self.send(referencia.referencename,entry,referencia)        
      end
    end
  end

  def aps_factura_print(filename)
    self.save_pdf_to(filename)    
  end

  def cnsp_factura_print(filename)
    Prawn::Document.generate(filename) do |pdf|
       pdf.draw_text "original " + self.type + " " + format("%04d" % self.sale_point).to_s + "-" + format("%08d" % self.numero).to_s, :at => [-24,400], :size => 8, :rotate => 90

       #pdf.draw_text self.cliente.condicioniva.letra.to_s, :at => [243,710], :size => 16
       #pdf.draw_text self.type + "Pto de venta:" + format("%04d" % self.sale_point).to_s + " Comp.Numero:" + format("%08d" % self.numero).to_s, :at => [270,710], :size => 10
       pdf.draw_text self.fecha.to_s, :at => [450,690], :size => 12
       
       #pdf.draw_text "Razon Social : " + self.cliente.company.name.to_s, :at => [10,685], :size => 10
       #pdf.draw_text "CUIT : " + self.cliente.company.cuit.to_s, :at => [280,685], :size => 10
       #pdf.draw_text "Direccion : " + self.cliente.company.address.to_s, :at => [10,675], :size => 10
       #pdf.draw_text "IIBB : " + self.cliente.company.iibb.to_s, :at => [280,675], :size => 10
       #pdf.draw_text "Condicion frente al IVA : " + self.cliente.company.condicioniva.detalle.to_s, :at => [10,665], :size => 10
       #pdf.draw_text "Inicio actividad : " + self.cliente.company.date_since.to_s, :at => [280,665], :size => 10
       
       # pdf.draw_text self.cliente.company.address.to_s, :at => [300,675], :size => 10

       pdf.draw_text self.cliente.razonsocial, :at => [0,610], :size => 12
       pdf.draw_text "Leg. : " + self.cliente.codigo + " - cuit : " + self.cliente.cuit, :at => [0,595], :size => 12
       pdf.draw_text self.cliente.condicioniva.detalle, :at => [0,580], :size => 12
       pdf.draw_text self.cliente.direccion, :at => [0,570], :size => 12
       
       pdf.draw_text self.formapago.try(:name), :at => [50,550], :size => 12
       
       pdf.draw_text "Descripcion" ,   :at => [1,515], :size => 12
       pdf.draw_text "Precio"  ,   :at => [400,515], :size => 12
       pdf.draw_text "Cant.",   :at => [450,515], :size => 12
       pdf.draw_text "Total"   ,   :at => [500,515], :size => 12  


      # inicion de tabla
      pdf.move_down 220

      data = []
      data << []

      self.detalles.each do |reg|
        line = []
        line << reg.descripcion.to_s
        line << format("%.2f" % reg.preciounitario).to_s
        line << format("%5d" % reg.cantidad).to_s
        line << format("%.2f" % reg.totalitem).to_s

        data << line
      end
      
      pdf.table(data, :column_widths => [400, 50, 40, 50],
             :cell_style => { :borders => [],
                              :size => 12,:padding => [0,3,4,2],
                              :align =>  :left,
                              :valign => :center } ) do
                                columns(1..3).align = :right
                              end
      # fin de tabla


      # @banda = 550   
      # self.detalles.each do |item|
      #    pdf.text_box item.descripcion.to_s(), :at => [1,@banda], :size => 10, :width => 400, :height => 50, :single_line => false
      #    
      #    pdf.draw_text item.preciounitario.to_s, :at => [400,@banda], :size => 10
      #    pdf.draw_text format("%5d" % item.cantidad).to_s, :at => [450,@banda], :size => 10
      #    pdf.draw_text format("%.2f" % item.totalitem).to_s.rjust(10), :at => [500,@banda], :size => 10
      #    @banda -= 15          
      # end
       #pdf.draw_text "Total", :at => [400,45], :size => 10

       pdf.draw_text "%9.02f" % self.importe.to_s, :at => [490,45], :size => 12, :style => :bold

       pdf.text_box Apslabs::Numlet.new.numero_a_palabras( self.importe ) + '.-', :at => [0,45], :size => 10, :width => 350, :height => 100, :single_line => false

       pdf.text_box self.cliente.company.facturaobservation.to_s , :at => [0,30], :size => 10, :width => 350, :height => 100, :single_line => false

       self.update_attributes(:printed_at => Date.today)
     end
  end

  def save_pdf_to(filename)
     Prawn::Document.generate(filename) do |pdf|
       pdf.draw_text "original", :at => [-4,400], :size => 8, :rotate => 90

       pdf.draw_text self.cliente.condicioniva.letra.to_s, :at => [243,710], :size => 16
       pdf.draw_text self.type + "Pto de venta:" + format("%04d" % self.sale_point).to_s + " Comp.Numero:" + format("%08d" % self.numero).to_s, :at => [270,710], :size => 10
       pdf.draw_text "Fecha de emision: " + self.fecha.to_s, :at => [280,695], :size => 10
       
       empresa = "public/images/" + self.cliente.company.logo_filename # logo.png
       pdf.image empresa, :at => [0,729], :width => 100

       pdf.draw_text "Razon Social : " + self.cliente.company.name.to_s, :at => [10,685], :size => 10
       pdf.draw_text "CUIT : " + self.cliente.company.cuit.to_s, :at => [280,685], :size => 10
       pdf.draw_text "Direccion : " + self.cliente.company.address.to_s, :at => [10,675], :size => 10
       pdf.draw_text "IIBB : " + self.cliente.company.iibb.to_s, :at => [280,675], :size => 10
       pdf.draw_text "Condicion frente al IVA : " + self.cliente.company.condicioniva.detalle.to_s, :at => [10,665], :size => 10
       pdf.draw_text "Inicio actividad : " + self.cliente.company.date_since.to_s, :at => [280,665], :size => 10
       
       # pdf.draw_text self.cliente.company.address.to_s, :at => [300,675], :size => 10

       # recuadro de los datos del cliente       
       pdf.line_width = 1
       pdf.bounding_box [-2, 730], :width => 500, :height => 70 do
           pdf.stroke_bounds
       end

       # recuadro de la letra
       pdf.line_width = 1
       pdf.bounding_box [233, 730], :width => 30, :height => 30 do
           pdf.stroke_bounds
       end

       pdf.draw_text "Razon social : " + self.cliente.razonsocial, :at => [10,650], :size => 10
       pdf.draw_text "CUIT : " + self.cliente.cuit, :at => [10,640], :size => 10
       pdf.draw_text "Condicion de IVA:" + self.cliente.condicioniva.detalle, :at => [10,630], :size => 10
       pdf.draw_text "Direccion : " + self.cliente.direccion, :at => [10,620], :size => 10
       pdf.draw_text "Forma de pago : " + self.formapago.try(:name), :at => [10,610], :size => 10
       
       # recuadro de los datos del cliente       
       pdf.line_width = 1
       pdf.bounding_box [-2, 730], :width => 500, :height => 150 do
           pdf.stroke_bounds
       end

       pdf.draw_text "Cantidad",   :at => [  1,565], :size => 10
       pdf.draw_text "U.Medida",   :at => [ 50,565], :size => 10
       pdf.draw_text "Detalle" ,   :at => [100,565], :size => 10
       pdf.draw_text "Precio"  ,   :at => [250,565], :size => 10
       pdf.draw_text "% IVA"   ,   :at => [300,565], :size => 10       
       pdf.draw_text "$ IVA"   ,   :at => [350,565], :size => 10        
       pdf.draw_text "Total"   ,   :at => [400,565], :size => 10   
       
       # recuadro 
       pdf.line_width = 1
       pdf.bounding_box [-2, 580], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end

       @banda = 550   
       self.detalles.each do |item|
          pdf.draw_text format("%5d" % item.cantidad).to_s, :at => [1,@banda], :size => 10
          pdf.draw_text item.product.unitmeasure.try(:name).to_s, :at => [50,@banda], :size => 10 
                   
          #pdf.draw_text item.descripcion.to_s(), :at => [100,@banda], :size => 10
          pdf.text_box item.descripcion.to_s(), :at => [100,@banda], :size => 10, :width => 150, :height => 100, :single_line => false
          
          pdf.draw_text item.preciounitario.to_s(), :at => [250,@banda], :size => 10
          pdf.draw_text item.tasaiva.to_s(), :at => [300,@banda], :size => 10          
          pdf.draw_text item.totalivaitem.to_s(), :at => [350,@banda], :size => 10
          pdf.draw_text format("%.2f" % item.totalitem).to_s().rjust(10), :at => [400,@banda], :size => 10
          @banda -= 15          
       end

       pdf.line_width = 1
       pdf.bounding_box [-2, 560], :width => 500, :height => 520 do
         pdf.stroke_bounds          
       end

       pdf.draw_text "Total IVA", :at => [350,45], :size => 10
       pdf.draw_text "Total", :at => [400,45], :size => 10

       pdf.line_width = 1
       pdf.bounding_box [-2, 60], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       pdf.draw_text "%9.02f" % self.total_iva_factura.to_s, :at => [350,25], :size => 12, :style => :bold
       pdf.draw_text "%9.02f" % self.importe.to_s, :at => [400,25], :size => 12, :style => :bold

       #pdf.draw_text current_user.email , :at => [0,5], :size => 12, :style => :bold

       pdf.line_width = 1
       pdf.bounding_box [-2, 40], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       self.update_attributes(:printed_at => Date.today)
     end
  end
end