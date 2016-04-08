class ItemsController < ApplicationController

  before_action :require_current_user
  before_action :set_item, only: [:new, :edit, :create, :update, :destroy, :complete, :clear]
  before_action :set_parent_items, only: [:new, :create, :edit, :update]

  def index
    if params[:id].present?
      @parent = Item.find params[:id]
      @items = @parent.children.not_cleared
      @clearable_items_count = @parent.descendants.completed.not_cleared.count
    else
      @items = current_user.items.roots.not_cleared
      @clearable_items_count = current_user.items.completed.not_cleared.count
    end

    @items = @items.order(:order, :created_at)
  end

  def new
  end

  def edit
  end

  def create
    if @item.save
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :edit
    end
  end

  def destroy
    parent_item = @item.parent
    @item.destroy

    redirect_to items_url(parent_item)
  end

  def complete
    @item.update completed: !@item.completed?

    redirect_to items_url(@item.parent, anchor: "item-#{@item.id}")
  end

  def clear
    result = if @item.present?
      @item.descendants.completed.update_all cleared: true
    else
      current_user.items.completed.update_all cleared: true
    end

    render text: "#{result} item(s) cleared."
  end

  def reorder
    params[:ids].split(",").each_with_index do |id, i|
      Item.find(id).update order: i
    end
  end

private

  def set_item
    if params[:id].present?
      @item = current_user.items.find params[:id]
    elsif params[:item].present?
      @item = current_user.items.new item_params
    end
  end

  def set_parent_items
    @parent_items = current_user.items.order(:name)

    if @item.present? && @item.persisted?
      @parent_items = @parent_items.where("id <> ?", @item.id)
    end
  end

  def item_params
    params.require(:item).permit(:name, :parent_id, :completed)
  end

end
