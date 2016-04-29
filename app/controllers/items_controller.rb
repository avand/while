class ItemsController < ApplicationController

  include ItemsHelper

  before_action :require_current_user
  before_action :set_item, only: [
    :new, :edit, :create, :update, :destroy, :complete, :clear, :adopt]
  before_action :set_parent_items, only: [:new, :edit, :create, :update]

  def index
    if params[:id].present?
      @parent = Item.find params[:id]
      @root = @parent.root
      @items = @parent.children.not_cleared
      @clearable_items_count = @parent.descendants.completed.not_cleared.count
    else
      @items = current_user.items.roots.not_cleared
      @clearable_items_count = current_user.items.completed.not_cleared.count
    end

    @items = @items.order(:order, :created_at)

    @breadcrumbs = [["Items", items_path]]
    if @parent.present?
      @breadcrumbs += @parent.ancestors.map { |i| [i.name, items_path(i)] }
      @breadcrumbs << [@parent.name, items_path(@parent)]
    end
  end

  def new
  end

  def edit
  end

  def create
    if @item.save
      current_user.log_action "created item"
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      current_user.log_action "updated item"
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
    if params[:completed_at].present?
      f = @item.update completed_at: params[:completed_at]
    else
      @item.update completed_at: nil
    end

    if request.xhr?
      render json: @item
    else
      redirect_to items_url(@item.parent, anchor: "item-#{@item.id}")
    end
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

  def adopt
    child_item = Item.find(params[:child_id])

    child_item.parent = @item
    child_item.make_last
    child_item.save

    total = @item.descendants.not_archived.count
    completed = @item.descendants.completed.not_archived.count

    render json: {
      progress_width: progress_bar_width(total),
      progress_bar_width: ((completed / total.to_f) * 100).round
    }
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
    if @item.present? && @item.persisted? && !@item.root?
      @parent_items = @item.ancestors.not_archived.order(:ancestry)
    end
  end

  def item_params
    params.require(:item).permit(:name, :parent_id, :completed, :color)
  end

end
