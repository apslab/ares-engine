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

  attr_accessible :detalle, :porcentaje, :since, :until

  # control para 
  #before_destroy :control_sin_items_comprobantes
    
  def control_sin_items_comprobantes
   if [detalles].any? {|detalle| detalle.any? }
     self.errors[:base] = "error que queres hacer?"
     return false
   end   
  end
    
  def _account_id
    _read_attribute(:account_id) || Refenciacontable.find_by_referencename_and_company_id('ventas_factura_iva',read_attribute(:company_id)).try(:account_id)
  end
end
