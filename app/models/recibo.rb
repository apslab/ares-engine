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
  
  belongs_to :cliente
  has_many :facturarecibos
    
  def total_recibo
    self.importe
  end
  
  def total_comprobante
    (self.importe * -1)
  end

  def total_monto_cancelado
    self.facturarecibos.all.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.importe - self.total_monto_cancelado
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

  def save_pdf_to(filename)
     Prawn::Document.generate(filename) do |pdf|
       pdf.draw_text "original", :at => [-4,400], :size => 8, :rotate => 90

       pdf.draw_text self.cliente.condicioniva.letra.to_s, :at => [243,710], :size => 16
       pdf.draw_text "Recibo numero: 0000-" + self.numero.to_s, :at => [300,710], :size => 14
       pdf.draw_text "Fecha de emision: " + self.fecha.to_s, :at => [300,695], :size => 14
       
       empresa = "public/images/clinicA.jpg" 
       pdf.image empresa, :at => [0,729], :width => 100

       # recuadro de la letra
       pdf.line_width = 1
       pdf.bounding_box [233, 730], :width => 30, :height => 30 do
           pdf.stroke_bounds
       end

       pdf.draw_text "Cliente", :at => [10,650], :size => 10, :style => :bold
       pdf.draw_text "Razon social : " + self.cliente.razonsocial, :at => [10,640], :size => 10
       pdf.draw_text "CUIT : " + self.cliente.cuit, :at => [10,630], :size => 10
       pdf.draw_text "Condicion de IVA:" + self.cliente.condicioniva.detalle, :at => [10,620], :size => 10
       pdf.draw_text "Direccion : " + self.cliente.direccion, :at => [10,610], :size => 10
       
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
       
       pdf.draw_text "%9.02f" % self.importe.to_s, :at => [400,25], :size => 12, :style => :bold

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
