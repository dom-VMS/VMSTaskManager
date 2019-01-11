class TaskQueuesController < ApplicationController
    before_action :set_queue, only: [:show, :edit, :update, :destroy]

    # GET /queues
    # GET /queues.json
    def index
      @queues = queue.order(:position)
    end
  
    def sort
      params[:queue].each_with_index do |id, index|
        TaskQueue.where(id: id).update_all(position: index + 1)
      end
  
      head :ok
    end
  
    # GET /queues/1
    # GET /queues/1.json
    def show
    end
  
    # GET /queues/new
    def new
      @queue = TaskQueue.new
    end
  
    # GET /queues/1/edit
    def edit
    end
  
    # POST /queues
    # POST /queues.json
    def create
      @queue = TaskQueue.new(queue_params)
  
      respond_to do |format|
        if @queue.save
          format.html { redirect_to @queue, notice: 'queue was successfully created.' }
          format.json { render :show, status: :created, location: @queue }
        else
          format.html { render :new }
          format.json { render json: @queue.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /queues/1
    # PATCH/PUT /queues/1.json
    def update
      respond_to do |format|
        if @queue.update(queue_params)
          format.html { redirect_to @queue, notice: 'queue was successfully updated.' }
          format.json { render :show, status: :ok, location: @queue }
        else
          format.html { render :edit }
          format.json { render json: @queue.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /queues/1
    # DELETE /queues/1.json
    def destroy
      @queue.destroy
      respond_to do |format|
        format.html { redirect_to queues_url, notice: 'queue was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_queue
        @queue = TaskQueue.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def queue_params
        params.require(:queue).permit(:name)
      end
  end
end
