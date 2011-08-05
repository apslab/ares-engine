# == Schema Information
# Schema version: 20110427212004
#
# Table name: tasaivas
#
#  id          :integer         not null, primary key
#  detalle     :string(255)
#  porcentaje  :decimal(, )
#  since       :date
#  until       :date
#  company_id  :integer
#  account_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Tasaiva < ActiveRecord::Base
  belongs_to :account
  belongs_to :company
  has_many :detalles
  
  validates :porcentaje, :presence => true
  
  scope :by_company, lambda {|company| where(:company_id => company.id) }

  # control para 
  #before_destroy :control_sin_items_comprobantes
    
  def control_sin_items_comprobantes
   if [detalles].any? {|detalle| detalle.any? }
     self.errors[:base] = "error que queres hacer?"
     return false
   end   
  end
  
  def save_pdf_to(filename)
    Prawn::Document.generate(filename) do |pdf|
      pdf.draw_text "original", :at => [-4,400], :size => 8, :rotate => 90
      offset = 800
      self.attributes.each do |member|
        offset -= 20
        pdf.draw_text member[0], :at => [0,offset], :size => 10
        pdf.draw_text member[1], :at => [100,offset], :size => 12
      end
    end
  end  
  
  def _account_id
    _read_attribute(:account_id) || Refenciacontable.find_by_referencename_and_company_id('ventas_factura_iva',read_attribute(:company_id)).try(:account_id)
  end
end
