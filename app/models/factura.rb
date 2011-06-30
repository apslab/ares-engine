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
  
  belongs_to :cliente
  has_many :facturarecibos
  has_many :facturanotacreditos
  
  scope :no_actualizados, where("updated_at IS NULL" )
  scope :vencidas, where("fechavto < ?", Date.today)
  scope :por_cliente, lambda {|cliente| where(:cliente_id => cliente) }

  def total_comprobante
    self.importe
  end
  
  def total_iva_factura
    detalles.all.sum(&:totalivaitem)
  end

  def isprinted?
    printed_at?
  end
  
  def total_monto_cancelado
    self.facturarecibos.all.sum(&:importe) + self.facturanotacreditos.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.importe - self.total_monto_cancelado
  end
   
  #properties for entry 
  def ventas_factura_total(*args)
    entry,referencia = args
    
    self.importe
  end 
   
  def ventas_factura_subtotal(*args)
    options = args.extract_options! # para permitir flexibilidad a la hora de pasar parametros por hash
    entry,referencia = args
    
    x = detalles.group_by{|detalle| detalle.product.account_id} 

    x.each do |account_id, detalles|
      total = detalles.sum{|detalle| detalle.importe} 

      entry.details.build do |dt|
        dt.account_id  = account_id  #referencia.account_id
        dt.description = __method__ + ' fc' + self.numero.to_s

        dt.credit      = referencia.debita? ? 0 : total
        dt.debit       = referencia.debita? ? total : 0      
      end
    end 
    #self.importe - self.total_iva_factura
  end
  
  def ventas_factura_iva(entry)
    self.total_iva_factura
  end

  def ventas_factura_iibb(entry)
    0.0
  end  
  #end properties for entry
      
  def to_entry
    Entry.new do |entry|
      entry.date_on     = self.fecha
      entry.description = self.cliente.razonsocial.to_s
      entry.exercise_id = self.cliente.company.exercises.where('started_on <= :fecha and finished_on >= :fecha',:fecha => self.fecha).first.try(:id)
      
      # cada referencia es mapeada al asiento
      ref = self.cliente.company.refenciacontables.where('referencename like "ventas_factura_%"')
      
      ref.each do |referencia|
        raise "falta metodo #{referencia.referencename}" unless self.respond_to?(referencia.referencename)
        
        next if self.send(referencia.referencename,entry,referencia)        
      end
    end
  end


  def account_for_reference(ref)
    if ref = 'ventas_factura_subtotal'
       return details.account_id.presence || ref.account_id
    else  
detalles.asiento_patial
ventas_factura_iva

    return ref.account_id unless ref.referencename.include?('ventas_factura_total')
    return cliente.account_id.presence || ref.account_id

# por cada item de la factura debo tomar su cuenta si la tiene cargada...
    [cuenta,importe] = detalle.asiento each do |item|
      item.account_id.presence || ref.account_id 'ventas_factura_subtotal'
      item.tasaiva.account_id.presence || ref.account_id 'ventas_factura_iva'
    end
  end

  def save_pdf_to(filename)
     Prawn::Document.generate(filename) do |pdf|
       pdf.draw_text "original", :at => [-4,400], :size => 8, :rotate => 90

       pdf.draw_text self.cliente.condicioniva.letra.to_s, :at => [243,710], :size => 16
       pdf.draw_text "Factura numero: 0000-" + self.numero.to_s, :at => [300,710], :size => 14
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

       pdf.draw_text "Cantidad",   :at => [  1,565], :size => 10
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
          pdf.draw_text format("%5d" % item.cantidad).to_s(), :at => [1,@banda], :size => 10
          pdf.draw_text item.descripcion.to_s(), :at => [100,@banda], :size => 10
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

       pdf.line_width = 1
       pdf.bounding_box [-2, 40], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       self.update_attributes(:printed_at => Date.today)
     end
  end
end