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

class Notacredito < Comprobante  
  scope :no_actualizados, where("updated_at IS NULL" )
  scope :por_cliente, lambda {|cliente| where(:cliente_id => cliente) }

  def total_notacredito
    self.importe
  end
  
  def signo
    -1
  end
  
  def total_iva_notacredito
    detalles.all.sum(&:totalivaitem)
  end

  def isprinted?
    printed_at?
  end
  
  def total_monto_cancelado
    self.facturanotacreditos.all.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.importe - self.total_monto_cancelado
  end

  def isprinted?
    printed_at?
  end

  def sin_deuda?
    total_monto_adeudado == 0
  end

  def con_deuda?
    total_monto_adeudado > 0
  end
   
  #properties for entry 
  def ventas_nc_total(*args)
    entry,referencia = args

    entry.details.build do |dt|
      dt.account_id  = self.cliente.account_id.presence || referencia.account_id      
      dt.description = __method__.to_s.humanize + ' fc' + self.numero.to_s

      dt.credit      = referencia.debita? ? 0 : self.importe
      dt.debit       = referencia.debita? ? self.importe : 0      
    end
  end 
   
  def ventas_nc_subtotal(*args)
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
  
  def ventas_nc_iva(*args)
    entry,referencia = args
    x = detalles.reject{|detalle| detalle.totalivaitem.zero?}.group_by{|detalle| detalle.product.tasaiva.account_id} 

    x.each do |account_id, detalles|
      total = detalles.sum{|detalle| detalle.totalivaitem} 
      # description = detalles.product.tasaiva.
      
      #unless total.zero? 
        entry.details.build do |dt|
          dt.account_id  = account_id || referencia.account_id
          dt.description = __method__.to_s.humanize + ' fc' + self.numero.to_s
          dt.credit      = referencia.debita? ? 0 : total
          dt.debit       = referencia.debita? ? total : 0      
        end
      #end

    end 
    
    #self.total_iva_factura
  end

  def ventas_nc_iibb(*args)
    0.0
  end  
  #end properties for entry
      
  def to_entry
    Entry.new do |entry|
      entry.date_on     = self.fecha
      entry.description = self.cliente.razonsocial.to_s
      entry.exercise_id = self.cliente.company.exercises.where('started_on <= :fecha and finished_on >= :fecha',:fecha => self.fecha).first.try(:id)
      
      # cada referencia es mapeada al asiento
      ref = self.cliente.company.refenciacontables.where('referencename like "ventas_nc_%"')
      
      ref.each do |referencia|
        raise "falta metodo #{referencia.referencename}" unless self.respond_to?(referencia.referencename)
        
        next if self.send(referencia.referencename,entry,referencia)        
      end
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

       # recuadro de la letra
       pdf.line_width = 1
       pdf.bounding_box [233, 730], :width => 30, :height => 30 do
           pdf.stroke_bounds
       end

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
       #pdf.draw_text "Forma de pago : " + self.try(:formapago).try(:name), :at => [10,610], :size => 10
       
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
       
       pdf.draw_text "%9.02f" % self.total_iva_notacredito.to_s, :at => [350,25], :size => 12, :style => :bold
       pdf.draw_text "%9.02f" % self.importe.to_s, :at => [400,25], :size => 12, :style => :bold

       pdf.line_width = 1
       pdf.bounding_box [-2, 40], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       self.update_attributes(:printed_at => Date.today)
     end
  end 
end
