class FacturasController < AuthorizedController
  before_filter :find_cliente
  before_filter :find_factura, :except => [:index, :new, :create]

  # GET /facturas
  # GET /facturas.xml
  
  def index
    @search = @cliente.facturas.search(params[:search])
    @facturas = @search.page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @facturas }
      format.pdf do
         dump_tmp_filename = Rails.root.join('tmp',@facturas.first.cache_key)
         Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
         save_list_pdf_to(dump_tmp_filename,@facturas) 
         send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "facturas.pdf")
         File.delete(dump_tmp_filename)           
      end      
    end
  end

  # GET /facturas/1
  # GET /facturas/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @factura }
      format.pdf do
       
        #unless @factura.isprinted?
           @entry = @factura.to_entry
           unless @entry.save
             flash[:error] = @entry.errors.full_messages.join("\n")
             redirect_to [@factura.cliente]
             return
           end
        #end
        

        dump_tmp_filename = Rails.root.join('tmp',@factura.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        
        if @factura.cliente.company.factura_method_print.blank?
          @factura.save_pdf_to(dump_tmp_filename) 
        else
          if @factura.respond_to?(@factura.cliente.company.factura_method_print)
            @factura.send( @factura.cliente.company.factura_method_print , dump_tmp_filename )
          end  
        end

        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@cliente.razonsocial}-factura-#{@factura.numero}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /facturas/new
  # GET /facturas/new.xml
  def new
    @factura = @cliente.facturas.build
    @factura.fecha = Date.today
    @factura.fechavto = Date.today
    @factura.detalles.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @factura }
    end
  end

  # GET /facturas/1/edit
  def edit
  end

  # POST /facturas
  # POST /facturas.xml
  def create
    @factura = @cliente.facturas.build(params[:factura])

    respond_to do |format|
      if @factura.save
        format.html { redirect_to([@cliente, @factura], :notice => t('flash.actions.create.notice', :resource_name => Factura.model_name.human)) }
        format.xml  { render :xml => @factura, :status => :created, :location => [@cliente, @factura] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @factura.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facturas/1
  # PUT /facturas/1.xml
  def update
    respond_to do |format|
      if @factura.update_attributes(params[:factura])
        format.html { redirect_to([@cliente, @factura], :notice => t('flash.actions.update.notice', :resource_name => Factura.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @factura.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /facturas/1
  # DELETE /facturas/1.xml
  def destroy
    @factura.destroy unless @factura.isprinted?

    respond_to do |format|
      format.html { redirect_to(cliente_facturas_url(@cliente)) }
      format.xml  { head :ok }
    end
  end

   protected 

   def find_cliente
     @cliente = Cliente.find(params[:cliente_id])
   end

   def find_factura
     @factura = @cliente.facturas.find(params[:id])
   end
end
