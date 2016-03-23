class ItemsController < ApplicationController

  before_action :require_current_user
  before_action :set_item, only: [:new, :edit, :create, :update, :destroy]
  before_action :set_parent_items, only: [:new, :create, :edit, :update]

  def index
    if params[:parent_id].present?
      @parent = Item.find params[:parent_id]
      @items = @parent.children
    else
      @items = current_user.items.roots
    end
  end

  def new
  end

  def edit
  end

  def create
    if @item.save
      redirect_to items_path(@item.parent), notice: "Item was successfully created."
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to items_path(@item.parent), notice: "Item was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    parent_item = @item.parent
    @item.destroy

    redirect_to items_url(parent_item), notice: "Item was successfully destroyed."
  end

private

  def set_item
    if params[:id].present?
      @item = Item.find params[:id]
    else
      @item = current_user.items.new item_params
    end
  end

  def set_parent_items
    @parent_items = Item.order(:name)

    if @item.present? && @item.persisted?
      @parent_items = @parent_items.where("id <> ?", @item.id)
    end
  end

  def item_params
    params.require(:item).permit(:name, :parent_id, :completed)
  end

end
