# == Schema Information
# Schema version: 20110512124317
#
# Table name: condicionivas
#
#  id         :integer         not null, primary key
#  detalle    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  letra      :string(255)
#  empresa_id :integer
#

class Condicioniva < ActiveRecord::Base
  has_many :clientes, :dependent => :restrict
  belongs_to :company, :class_name => "Company", :foreign_key => "empresa_id"

  scope :by_company, lambda {|company| where(:empresa_id => company.id) } 
  
  validates :detalle, :presence => true
  validates :letra, :presence => true

  attr_accessible :detalle, :letra, :empresa_id  
end
