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
#  company_id      :integer
#

class Cliente < ActiveRecord::Base
  has_many :facturas
  has_many :recibos
  has_many :notacreditos
  #has_many :debitos, :class_name => "Comprobante" #, :foreign_key => "reference_id"
  #scope :debitos, where("comprobantes.signo = 1 ")

  has_many :comprobantedebitos
  has_many :comprobantecreditos  
  has_many :comprobantes do 
    def saldo
      fc = where("Type = 'Factura'").sum(:importe)
      nc = where("Type = 'Notacredito'").sum(:importe)
      rc = where("Type = 'Recibo'").sum(:importe)
      cd = where("Type = 'Comprobantedebito'").sum(:importe)
      cc = where("Type = 'Comprobantecredito'").sum(:importe)
      fc + cd - nc - rc - cc
    end

    def debitos
      where("Type = 'Factura' or Type = 'Comprobantedebito'")
    end

    def creditos
      where("Type = 'Recibo' or Type = 'Notacredito' or Type = 'Comprobantecredito'")
    end
  end
  
  belongs_to :condicioniva
  belongs_to :account
  belongs_to :company
  belongs_to :province

  validates :razonsocial, :presence => true
  validates :codigo, :presence => true
  validates_uniqueness_of :codigo, :scope => [:company_id]
  
  validates :cuit,:length => { :maximum => 11, :minimum => 11 }, :allow_nil => true, :allow_blank => true
  validates :codigopostal,  :length => { :maximum => 7, :minimum => 4 }, :allow_nil => true, :allow_blank => true
  validates :localidad, :presence => true
  #validates_uniqueness_of :cuit, :scope => [:company_id], :message => "existe otra cuenta con el mismo cuit", :allow_blank => true

  validates_numericality_of :cuit, :only_integer => true, :message => "solo numeros", :allow_nil => true, :allow_blank => true
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => true, :allow_blank => true

  attr_accessible :razonsocial, :condicioniva_id, 
              :codigo, :cuit, :telefono, :direccion,
              :contacto, :account_id, :company_id,
              :email, :fantasyname, :codigopostal, :localidad,
              :province_id, :observation, :date_and_time_attention,
              :envelope

  scope :sin_telefono, where("clientes.telefono = '' ")
  scope :no_actualizados, where("updated_at IS NULL" )
  scope :orden_alfabetico, order("clientes.razonsocial")  
  scope :by_company, lambda {|company| where(:company_id => company.id) }
  
  delegate :saldo , :to => :comprobantes
  delegate :debitos , :to => :comprobantes
  delegate :creditos , :to => :comprobantes

  # control para 
  before_destroy :control_sin_comprobantes
  
  # funcionalidad: accesible_by(current_ability)) 
  # 1) rails g cancan:ability
 
def save_ctacte_pdf_to(filename,entity)
  require 'prawn'
    
  pdf = Prawn::Document.new(:left_margin => 35, :top_margin => 35,:page_size   => "LETTER",
                            :page_layout => :portrait)
  offset = 0

  pdf.repeat(:all, :dynamic => true) do
    pdf.draw_text ("Cuenta corriente de " + entity.first.try(:cliente).razonsocial + " impreso el " + Date.today.strftime("%d/%m/%Y")) , :at => [5,745],:style => :bold, :size => 10
    pdf.draw_text "Hoja Nro.: " + pdf.page_number.to_s.rjust(4,"0"), :at => [300, 745],:style => :bold, :size => 8
  end
  data = [["Fecha","Tipo Cp","Numero","Importe","Fecha Vto","impreso"],[] ]
  saldo = 0
  entity.each do |r|
     data << [r.fecha.blank? ? '' : r.fecha.strftime("%d/%m/%Y"),
              r.type,
              r.numero,
              r.total_comprobante,
              r.fechavto.blank? ? '' : r.fechavto.strftime("%d/%m/%Y"),
              r.printed_at.blank? ? '' : r.printed_at.strftime("%d/%m/%Y")]
      saldo += r.total_comprobante       
  end
  data << ["" ,"Totales","",saldo.to_s,"",""  ]

  pdf.table(data, :column_widths => [65, 100, 60, 65, 65, 65],
           :cell_style => { :font => "Times-Roman",
                            :size => 10,:padding => [2,3,4,2],
                            :align =>  :left,
                            :valign => :center },
           :header => true ,
           :row_colors => ["F0F0F0", "FFFFCC"]
            ) do
    column(2...3).align = :right
    row(0).column(0..6).align = :center
  end
  pdf.render_file(filename)
end
#
  def control_sin_comprobantes
   if [comprobantes].any? {|cpbte| cpbte.any? }
     errors.add(:base,"La cuenta posee " + comprobantes.count.to_s() + " comprobantes asociado.")
     return false
   end   
  end
  
  def _account_id
    _read_attribute(:account_id) || Refenciacontable.find_by_referencename_and_company_id('ventas_factura_total',read_attribute(:company_id)).try(:account_id)
  end    
end
