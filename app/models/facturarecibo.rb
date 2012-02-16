# == Schema Information
# Schema version: 20110427202648
#
# Table name: facturarecibos
#
#  id         :integer         not null, primary key
#  factura_id :integer
#  fecha      :date
#  importe    :decimal(, )
#  recibo_id  :integer
#  created_at :datetime
#  updated_at :datetime

class Facturarecibo < ActiveRecord::Base
  belongs_to :factura
  belongs_to :recibo
  
  has_one :cliente, :through => :factura

  scope :por_cliente, lambda {|cliente| where(:cliente_id => cliente) }
  
  validate :factura_id, :presence => true
  validate :recibo_id, :presence => true
  validate :importe, :presence => true
  validate :fecha, :presence => true

  validate :check_importe
  
  def check_importe
    errors.add(:base, 
    'El Importe debe ser menor o igual al menor de los montos por cancelar') unless 
    importe <= self.factura.importe && importe <= self.recibo.importe
  end
   
  #TODO facturarecibo, tiene relaciones con muchas facturas y muchos recibos
end
