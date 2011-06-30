# == Schema Information
# Schema version: 20110512124317
#
# Table name: clientes
#
#  id              :integer         not null, primary key
#  codigo          :string(255)
#  razonsocial     :string(255)
#  cuit            :string(255)
#  telefono        :string(255)
#  direccion       :string(255)
#  contacto        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  condicioniva_id :integer
#  empresa_id      :integer
#

class Cliente < ActiveRecord::Base
  has_many :facturas
  has_many :recibos
  has_many :notacreditos
  has_many :comprobantes do 
    def saldo
      fc = where("Type = 'Factura'").sum(:importe)
      nc = where("Type = 'Notacredito'").sum(:importe)
      rc = where("Type = 'Recibo'").sum(:importe)
      fc - nc - rc
    end
  end
   
  belongs_to :condicioniva
  belongs_to :account
  belongs_to :company, :class_name => "Company", :foreign_key => "empresa_id"

  validates :razonsocial, :presence => true
  validates :codigo, :presence => true
  validates_uniqueness_of :codigo, :scope => [:empresa_id]
  
  validates :cuit, :allow_nil => true,:length => { :maximum => 11 }
  validates_uniqueness_of :cuit, :scope => [:empresa_id], :allow_nil => true
  validates_numericality_of :cuit, :only_integer => true, :message => "solo numeros", :allow_nil => true
  # validates_inclusion_of :cuit, :in => 20000000000..38000000000, :message => "solo puede ingresar numeros entre 20 y 38."

  attr_accessible :razonsocial, :condicioniva_id, :codigo, :cuit, :telefono, :direccion, :contacto, :empresa_id, :account_id

  scope :sin_telefono, where("clientes.telefono = '' ")
  scope :no_actualizados, where("updated_at IS NULL" )
  scope :orden_alfabetico, order("clientes.razonsocial")  
  scope :by_company, lambda {|company| where(:empresa_id => company.id) }
  
  delegate :saldo , :to => :comprobantes
  
  # control para 
  before_destroy :control_sin_comprobantes
  
  # funcionalidad: accesible_by(current_ability)) 
  # 1) rails g cancan:ability
  
  def control_sin_comprobantes
   if [comprobantes].any? {|cpbte| cpbte.any? }
     errors.add(:base,"La cuenta posee " + comprobantes.count.to_s() + " comprobantes asociado.")
     return false
   end   
  end
  
  def _account_id
    _read_attribute(:account_id) || Refenciacontable.find_by_referencename_and_company_id('ventas_factura_total',read_attribute(:empresa_id)).try(:account_id)
  end
    
end
