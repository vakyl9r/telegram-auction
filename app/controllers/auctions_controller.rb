class AuctionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_channel, only: [:new, :edit, :show, :index]
  before_action :set_auction, except: [:index, :new, :create]

  def index
    @auctions = Auction.all
  end

  def show
  end

  def new
    @auction = Auction.new
  end

  def edit
  end

  def create
    @auction = Auction.new(auction_params)

    respond_to do |format|
      if @auction.save
        format.html { redirect_to @auction, notice: 'Auction was successfully created.' }
        format.json { render :show, status: :created, location: @auction }
      else
        format.html { render :new }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @auction.update(auction_params)
        format.html { redirect_to @auction, notice: 'Auction was successfully updated.' }
        format.json { render :show, status: :ok, location: @auction }
      else
        format.html { render :edit }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @auction.destroy
    respond_to do |format|
      format.html { redirect_to auctions_url, notice: 'Auction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def start
    # StopAuctionJob.set(wait: @auction.auction_time.minutes).perform_later(@auction, 11, {})
    @auction.update(active: true)
    respond_to do |format|
      format.html { redirect_to @auction, notice: 'The auction started!' }
      format.json { head :no_content }
    end
  end

  def stop
    @auction.update(active: false)
    # StopAuctionJob.perform_now(@auction, 11, {})
    respond_to do |format|
      format.html { redirect_to @auction, notice: 'The auction is over!' }
      format.json { head :no_content }
    end
  end

  def destroy_logs
    @auction.telegram_logs.delete_all
    respond_to do |format|
      format.html { redirect_to @auction, notice: 'The Logs are deleted!' }
      format.json { head :no_content }
    end
  end

  private

  def set_auction
    @auction = Auction.find(params[:id])
  end

  def set_channel
    @channels = Channel.all
  end

  def auction_params
    params.require(:auction).permit(
      :name, :image_1, :image_2, :start_price, :bet_price, :current_price,
      :participants, :history, :description, :end_price, :auction_time, :channel
    )
  end
end
