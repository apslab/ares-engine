class NotacreditosController < AuthorizedController
  # GET /notacreditos
  # GET /notacreditos.xml
  before_filter :find_cliente
  before_filter :find_nc, :except => [:index, :new, :create]
  
  def index
    @search = @cliente.notacreditos.search(params[:search])
    @notacreditos = @search.page(params[ :page ]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notacreditos }
    end
  end

  # GET /notacreditos/1
  # GET /notacreditos/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notacredito }
      format.pdf do
       
        #unless @factura.isprinted?
           @entry = @notacredito.to_entry
           unless @entry.save
             flash[:error] = @entry.errors.full_messages.join("\n")
             redirect_to [@notacredito.cliente,:facturas]
             return
           end
        #end
        
        dump_tmp_filename = Rails.root.join('tmp',@notacredito.cache_key)
        Dir.mkdir(dump_tmp_filename.dirname) unless File.directory?(dump_tmp_filename.dirname)
        @notacredito.save_pdf_to(dump_tmp_filename)
        send_file(dump_tmp_filename, :type => :pdf, :disposition => 'attachment', :filename => "#{@notacredito.razonsocial}-factura-#{@notacredito.numero}.pdf")
        File.delete(dump_tmp_filename)
      end
    end
  end

  # GET /notacreditos/new
  # GET /notacreditos/new.xml
  def new
    @notacredito = @cliente.notacreditos.build    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notacredito }
    end
  end

  # GET /notacreditos/1/edit
  def edit
  end

  # POST /notacreditos
  # POST /notacreditos.xml
  def create
    @notacredito = @cliente.notacreditos.build(params[:notacredito])

    respond_to do |format|
      if @notacredito.save
        format.html { redirect_to([@cliente, @notacredito], :notice => 'nota de credito was successfully created.') }
        format.xml  { render :xml => @notacredito, :status => :created, :location => [@cliente, @notacredito] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @notacredito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notacreditos/1
  # PUT /notacreditos/1.xml
  def update
    respond_to do |format|
      if @notacredito.update_attributes(params[:notacredito])
        format.html { redirect_to([@cliente, @notacredito], :notice => 'Factura was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notacredito.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notacreditos/1
  # DELETE /notacreditos/1.xml
  def destroy
    @notacredito.destroy unless @notacredito.isprinted?

    respond_to do |format|
      format.html { redirect_to(cliente_notacreditos_url(@cliente)) }
      format.xml  { head :ok }
    end
  end
  
  protected 

  def find_cliente
    @cliente = Cliente.find(params[:cliente_id])
  end

  def find_nc
    @factura = @cliente.notacredito.find(params[:id])
  end  
end
