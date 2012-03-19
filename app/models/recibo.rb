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

class Recibo < Comprobante
  def total_recibo
    self.importe
  end
  
  def signo
    -1
  end

  def total_monto_cancelado
    self.debitoafectaciones.all.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.importe - self.total_monto_cancelado
  end

  def isprinted?
    printed_at?
  end
  
  def con_deuda?
    total_monto_adeudado > 0
  end
  
  def sin_deuda?
    total_monto_adeudado == 0
  end

  def ventas_recibo_total(*args)
    entry,referencia = args

    entry.details.build do |dt|
      dt.account_id  = self.cliente.account_id.presence || referencia.account_id      
      dt.description = __method__.to_s.humanize + ' rc' + self.numero.to_s

      dt.credit      = referencia.debita? ? 0 : self.importe
      dt.debit       = referencia.debita? ? self.importe : 0      
    end    
  end

  #TODO cambiar por imputacion contable por moneda
  def ventas_recibo_subtotal(*args)
    entry,referencia = args
    
    entry.details.build do |dt|
      dt.account_id  = referencia.account_id      
      dt.description = __method__.to_s.humanize + ' rc' + self.numero.to_s

      dt.credit      = referencia.debita? ? 0 : self.importe
      dt.debit       = referencia.debita? ? self.importe : 0      
    end
  end

  def to_entry
    Entry.new do |entry|
      entry.date_on     = self.fecha
      entry.description = self.cliente.razonsocial.to_s
      entry.exercise_id = self.cliente.company.exercises.where('started_on <= :fecha and finished_on >= :fecha',:fecha => self.fecha).first.try(:id)
      
      # cada referencia es mapeada al asiento
      ref = self.cliente.company.refenciacontables.where('referencename like ?',"ventas_recibo_%")
      
      ref.each do |referencia|
        raise "falta metodo #{referencia.referencename}" unless self.respond_to?(referencia.referencename)
        
        next if self.send(referencia.referencename,entry,referencia)        
      end
    end
  end

  def aps_recibo_print(filename)
    Prawn::Document.generate(filename) do |pdf|
      pdf.draw_text self.fecha.to_s, :at => [360,705], :size => 14, :style => :bold
    
      pdf.draw_text self.cliente.razonsocial, :at => [30,620], :size => 12
      pdf.draw_text 'CUIT: ' + self.cliente.cuit + ' - Direccion: ' + self.cliente.direccion, :at => [0,600], :size => 10
    
      pdf.draw_text Apslabs::Numlet.new.numero_a_palabras( self.importe ) + '.-', :at => [330,560]

      @line = 535
      @total_cpb = 0
      self.debitoafectaciones.each do |cpb|
        pdf.draw_text cpb.debito.fecha.to_s , :at => [-10,@line], :size => 8
        pdf.draw_text format("%04d" % cpb.debito.sale_point).to_s + '-' + format("%08d" % cpb.debito.numero).to_s , :at => [35,@line], :size => 8
        pdf.draw_text "%9.02f" % cpb.importe.to_s , :at => [130,@line], :size => 10
        @total_cpb += cpb.importe
        @line -= 15
      end
      pdf.draw_text "%9.02f" % @total_cpb.to_s, :at => [130,370], :size => 10, :style => :bold

      @banda = 520
      self.detalles.each do |item|  
         pdf.draw_text item.descripcion.to_s(), :at => [250,@banda], :size => 10
         pdf.draw_text format("%.2f" % item.totalitem).to_s().rjust(10), :at => [500,@banda], :size => 10
         @banda -= 15          
      end

      pdf.draw_text "%9.02f" % self.importe.to_s, :at => [300,370], :size => 14, :style => :bold
      pdf.draw_text self.type + " " + format("%04d" % self.sale_point).to_s + "-" + format("%08d" % self.numero).to_s, :at => [300,340], :size => 6

      self.update_attributes(:printed_at => Date.today)    
    end    
  end

  def cnsp_recibo_print(filename)
    Prawn::Document.generate(filename) do |pdf|
      pdf.draw_text self.fecha.to_s, :at => [360,705], :size => 14, :style => :bold
    
      pdf.draw_text self.cliente.razonsocial, :at => [30,620], :size => 12
      #pdf.draw_text self.cliente.condicioniva.name, :at => [10,600], :size => 10
      pdf.draw_text self.cliente.cuit, :at => [300,600], :size => 10
    
      pdf.draw_text Apslabs::Numlet.new.numero_a_palabras( self.importe ) + '.-', :at => [330,560]

      pdf.draw_text self.observation, :at => [400,500], :size => 10

      pdf.draw_text "%9.02f" % self.importe.to_s, :at => [100,370], :size => 14, :style => :bold
      pdf.draw_text self.type + " " + format("%04d" % self.sale_point).to_s + "-" + format("%08d" % self.numero).to_s, :at => [500,340], :size => 6

      self.update_attributes(:printed_at => Date.today)    
    end    
  end

  def save_pdf_to(filename)    
     Prawn::Document.generate(filename) do |pdf|
       pdf.draw_text "original", :at => [-4,400], :size => 8, :rotate => 90

       pdf.draw_text self.cliente.condicioniva.letra.to_s, :at => [243,710], :size => 16
       pdf.draw_text self.type + " Pto.venta: " + format("%04d" % self.sale_point).to_s + " Comp.Numero: " + format("%08d" % self.numero).to_s, :at => [270,710], :size => 10
       pdf.draw_text "Fecha de emision: " + self.fecha.to_s, :at => [300,695], :size => 14
       
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
       #pdf.draw_text "Forma de pago : " + self.formapago.try(:name), :at => [10,610], :size => 10
       
       
       # recuadro de los datos del cliente       
       pdf.line_width = 1
       pdf.bounding_box [-2, 730], :width => 500, :height => 150 do
           pdf.stroke_bounds
       end

       pdf.draw_text self.observation, :at => [1,585], :size => 10
       pdf.draw_text " ",   :at => [  1,565], :size => 10
       pdf.draw_text "Detalle" ,   :at => [100,565], :size => 10
       pdf.draw_text "Monto"  ,   :at => [250,565], :size => 10
       pdf.draw_text "Total"   ,   :at => [400,565], :size => 10   
       
       # recuadro 
       pdf.line_width = 1
        pdf.bounding_box [-2, 580], :width => 500, :height => 20 do
          pdf.stroke_bounds          
        end
       @banda = 550
       
       self.detalles.each do |item|  
          pdf.draw_text item.descripcion.to_s(), :at => [100,@banda], :size => 10
          pdf.draw_text item.preciounitario.to_s(), :at => [250,@banda], :size => 10
          pdf.draw_text format("%.2f" % item.totalitem).to_s().rjust(10), :at => [400,@banda], :size => 10
          @banda -= 15          
       end

       pdf.line_width = 1
       pdf.bounding_box [-2, 560], :width => 500, :height => 520 do
         pdf.stroke_bounds          
       end

       pdf.draw_text "Total", :at => [400,45], :size => 10

       pdf.line_width = 1
       pdf.bounding_box [-2, 60], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       pdf.draw_text format("%9.02f" % self.importe).to_s, :at => [400,25], :size => 12, :style => :bold

       pdf.line_width = 1
       pdf.bounding_box [-2, 40], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       self.update_attributes(:printed_at => Date.today)
     end
  end
    
protected
  #def calculo_total_comprobante
  #  self.importe =  8888
  #end   
end
