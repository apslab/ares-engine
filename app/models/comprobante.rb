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
  belongs_to :formapago
#  has_many :afectaciones
  has_many :debitoafectaciones, :class_name => "Afectacion", :foreign_key => :debito_id 
  has_many :creditoafectaciones, :class_name => "Afectacion", :foreign_key => :credito_id 


  has_many :detalles, :as => :detallable do
    def calculo_total_items
      map(&:totalitem).sum
    end
  end
  
  before_validation :calculo_total_comprobante
  
  accepts_nested_attributes_for :detalles, :allow_destroy => true, :reject_if => :all_blank  
  
  validates :fecha, :presence => true

  #TODO para ventas el unique funciona, para compras deber sumar la cuenta del proveedor  
  validates :sale_point, :presence => true, :length => { :maximum => 4 }, :numericality => true
  validates :numero, :presence => true, :length => { :maximum => 8 }, :numericality => true, :uniqueness => {:scope => [:type, :sale_point]}

  validates :importe, :numericality => {:greater_than => 0}

  #validates_numericality_of :importe, :greater_than => 0

  #TODO importe debe ser la suma de los totales de los items
  #validates :importe, :presence => true, :numericality => true
  
  def total_comprobante
    (self.importe * self.signo)
  end

  def count_items
    detalles.count
  end
    
  def total
    detalles.calculo_total_items
  end  
  
  protected
  def calculo_total_comprobante
    self.importe =  self.total
  end
end
