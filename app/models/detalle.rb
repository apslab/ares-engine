# == Schema Information
# Schema version: 20110516183603
#
# Table name: detalles
#
#  id              :integer         not null, primary key
#  detallable_id   :integer
#  detallable_type :string(255)
#  descripcion     :string(255)
#  cantidad        :decimal(, )
#  preciounitario  :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  tasaiva         :decimal(, )
#

class Detalle < ActiveRecord::Base
  belongs_to :detallable, :polymorphic => true
  belongs_to :product
    
  attr_accessible :cantidad, :descripcion, :preciounitario, :product_id, :tasaiva
  attr_accessor :totalitem

  validates :cantidad, :presence => true , :numericality => true, :numericality => { :greater_than => 0 }
  validates :preciounitario, :presence => true, :numericality => true, :numericality => { :greater_than => 0 }
  validates :descripcion, :presence => true
  validates :tasaiva, :presence => true, :numericality => true
  
  def totalivaitem
    self.tasaiva = 0 if self.tasaiva.nil?
    self.preciounitario = 0 if self.preciounitario.nil?
    self.cantidad = 0 if self.cantidad.nil?
    
    self.preciounitario * self.cantidad * (self.tasaiva/100)
  end  

  def totalitem
    self.tasaiva = 0 if self.tasaiva.nil?
    self.preciounitario = 0 if self.preciounitario.nil?
    self.cantidad = 0 if self.cantidad.nil?
    
    self.preciounitario * self.cantidad * (1 + (self.tasaiva/100))
  end  
end
