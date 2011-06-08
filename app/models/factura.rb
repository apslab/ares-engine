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
    self.total_factura
  end
  
  def total_iva_factura
    #facturadetalles.sum("preciounitario * cantidad * (1+(tasaiva/100))") 
    detalles.all.sum(&:totalivaitem)
  end

  def isprinted?
    printed_at?
  end
  
  def total_monto_cancelado
    self.facturarecibos.all.sum(&:importe) + self.facturanotacreditos.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.total_factura - self.total_monto_cancelado
  end
  
#contabilizar
=begin
  def factura_total
    account_by_part(_method_)
  end  

  def factura_subtotal
    account_by_part(_method_)    
  end
  
  def factura_impuesto
    account_by_part(_method_)    
  end
=end

  # ['factura_total','factura_subtotal','factura_impuesto']
  Comprobante.referencias.grep(/^factura_/).each do |methodname|
    define_method(methodname) { account_by_part(__method__) }    
  end

  Comprobante.referencias.grep(/^factura_/).each do |methodname|
    define_method(methodname) { account_by_part_debit(__method__ + 'debit?') }    
  end

  Comprobante.referencias.grep(/^factura_/).each do |methodname|
    define_method(methodname) { account_by_part_credit(__method__ + 'credit?') }    
  end

  def account_by_part(referencename)
    self.cliente.empresa.refenciacontables.find_by_referencename(referencename).account_id
  end

  def account_by_part_debit(referencename)
    self.cliente.empresa.refenciacontables.find_by_referencename(referencename).debita
  end

  def account_by_part_credit(referencename)
    not self.cliente.empresa.refenciacontables.find_by_referencename(referencename).debita
  end
    
  def to_entry
    Entry.new do |entry|
      entry.date_to = Date.today
      # cada referencia es mapeada al asiento
      Comprobante.referencias.grep(/^factura_/).each do |methodname|
        entry.details.new
        entry.details.account_id = self.factura_total()
        entry.details.description = methodname.to_s
        entry.details.credit = total_factura if self.factura_total_credit?
        entry.details.debit = total_factura if self.factura_total_debit?

        entry.details.new
        entry.details.account_id = self.factura_subtotal()
        entry.details.description = methodname.to_s
        entry.details.credit = subtotal_factura if self.factura_subtotal_credit?
        entry.details.debit = subtotal_factura if self.factura_subtotal_debit?

        entry.details.new
        entry.details.account_id = self.factura_iva()
        entry.details.description = methodname.to_s
        entry.details.credit = total_iva_factura if self.factura_iva_credit?
        entry.details.debit = total_iva_factura if self.factura_iva_debit?
      end
    end
    return entry
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
       
       pdf.draw_text self.total_iva_factura.to_s, :at => [350,25], :size => 12, :style => :bold
       pdf.draw_text self.importe.to_s, :at => [400,25], :size => 12, :style => :bold

       pdf.line_width = 1
       pdf.bounding_box [-2, 40], :width => 500, :height => 20 do
          pdf.stroke_bounds          
       end
       
       self.update_attributes(:printed_at => Date.today)
     end
  end
end

=begin
aqui en Factura

def to_entry
  returnig Entry.new do |Entry|
  # empiezo el mapping de
  entry.attributo = selffactura.elatributoquelocompleta
  end
end

de esa forma dado que tenes una factura
fac = Factura.first
llegas a su entry de contabilidad
asi
fac.to_entry
eso devuelve un objecto entry, listo para ser salvado
o lo que fuere
me explique o es medio chino?
lo piola de este approach es que te queda todo encapsulado en el modelo
es como hacer la factura xml
o jston
to_json, o to_xml
bueno aca es hacer la factura una entry de contable
to_entry

me quede pensando
no necesitas returning en este caso
poirque
Entry.new do |entry|
# inicializacion loca de entry
end
devuelve un obj Entry
=end
