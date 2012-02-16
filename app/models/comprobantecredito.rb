# comprobante credito
require 'prawn'


class Comprobantecredito < Comprobante
  def total_comprobante
    (self.importe * -1)
  end

  def total_monto_cancelado
    self.debitoafectaciones.all.sum(&:importe) 

    #self.facturarecibos.all.sum(&:importe)
  end
  
  def total_monto_adeudado
    self.importe - self.total_monto_cancelado
  end

  def isprinted?
    printed_at?
  end
  
  def con_deuda?
    total_monto_adeudado > 0
  end
  
  def sin_deuda?
    total_monto_adeudado == 0
  end

  def ventas_comprobantecredito_total(*args)
    entry,referencia = args

    entry.details.build do |dt|
      dt.account_id  = self.cliente.account_id.presence || referencia.account_id      
      dt.description = __method__.to_s.humanize + ' rc' + self.numero.to_s

      dt.credit      = referencia.debita? ? 0 : self.importe
      dt.debit       = referencia.debita? ? self.importe : 0      
    end    
  end

  #TODO cambiar por imputacion contable por moneda
  def ventas_comprobantecredito_subtotal(*args)
    entry,referencia = args
    
    entry.details.build do |dt|
      dt.account_id  = referencia.account_id      
      dt.description = __method__.to_s.humanize + ' rc' + self.numero.to_s

      dt.credit      = referencia.debita? ? 0 : self.importe
      dt.debit       = referencia.debita? ? self.importe : 0      
    end
  end

  def to_entry
    Entry.new do |entry|
      entry.date_on     = self.fecha
      entry.description = self.cliente.razonsocial.to_s
      entry.exercise_id = self.cliente.company.exercises.where('started_on <= :fecha and finished_on >= :fecha',:fecha => self.fecha).first.try(:id)
      
      # cada referencia es mapeada al asiento
      ref = self.cliente.company.refenciacontables.where('referencename like ?',"ventas_comprobantecredito_%")
      
      ref.each do |referencia|
        raise "falta metodo #{referencia.referencename}" unless self.respond_to?(referencia.referencename)
        
        next if self.send(referencia.referencename,entry,referencia)        
      end
    end
  end

  def save_pdf_to(filename)    
     Prawn::Document.generate(filename) do |pdf|
       pdf.draw_text "original comprobante de credito", :at => [-4,400], :size => 8, :rotate => 90
       
       self.update_attributes(:printed_at => Date.today)
     end
  end
end

