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

class Comprobante < ActiveRecord::Base
  belongs_to :cliente  
  has_many :detalles, :as => :detallable

  cattr_reader :referencias 

  before_save :calculo_total_comprobante
  
  accepts_nested_attributes_for :detalles, :allow_destroy => true, :reject_if => :all_blank  
  
  validates :fecha, :presence => true
  validates :numero, :presence => true, :length => { :maximum => 10 }, :uniqueness => true, :numericality => true

  #TODO importe debe ser la suma de los totales de los items
  #validates :importe, :presence => true, :numericality => true
  
  def count_items
    detalles.count
  end
    
  def total
    detalles.map(&:totalitem).sum
  end  
  
  def self.referencias
    ['factura_total','factura_subtotal','factura_iva','factura_iibb']
  end
  
protected
def calculo_total_comprobante
  self.importe =  detalles.sum("cantidad * preciounitario * (1+(tasaiva/100))")
end

  #def importe
  # where("Type = 'Factura'").sum(:importe)
  #  detalles.sum(:totalitem)
  #end        
end
