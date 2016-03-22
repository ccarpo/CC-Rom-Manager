class RomsController < ApplicationController
  def new
  end

  def index
    @roms = Rom.all
  end

  def show
    @rom = Rom.find(params[:id])
  end

  def edit
    @rom = Rom.find(params[:id])
  end

  def create
    @rom = Rom.new(rom_params)

    if @rom.save
      redirect_to @rom
    else
      render 'new'
    end
  end

  def update
    @rom = Rom.find(params[:id])

    if @rom.update(rom_params)
      redirect_to @rom
    else
      render 'edit'
    end
  end

  def destroy
    @rom = Rom.find(params[:id])
    @rom.destroy

    redirect_to roms_path
  end

private
  def rom_params
    params.require(:rom).permit(:title, :description, :publisher, :developer, :rating, :players, :frontcover, :frontcover_file_name)
  end

end
