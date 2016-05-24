class ItemsController < ApplicationController

  include ItemsHelper

  before_action :require_current_user
  before_action :set_item, only: [
    :new, :edit, :create, :update, :destroy, :complete, :adopt, :cleanup]
  before_action :set_parent_items, only: [:new, :edit, :create, :update]

  def index
    if params[:id].present?
      @parent = Item.find params[:id]
      @root = @parent.root
      @items = @parent.children
    else
      @items = current_user.items.roots
    end

    @items = @items.not_deleted

    archived_items = @items.archived.order("completed_at desc")
    @archived_items_by_completed_date = archived_items.group_by do |item|
      item.completed_at.to_date
    end

    @items = @items.not_archived.order(:order, :created_at)

    @ancestors = [["While", items_path]]
    if @parent.present?
      @ancestors += @parent.ancestors.map { |i| [i.name, items_path(i), i.id] }
      @ancestors << [@parent.name, items_path(@parent)]
    end
  end

  def new
  end

  def edit
  end

  def create
    if @item.save
      current_user.log_action "created item #{@item.id}"
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      current_user.log_action "updated item #{@item.id}"
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :edit
    end
  end

  def destroy
    @item.update deleted_at: params[:deleted_at]

    if request.xhr?
      render json: @item
    else
      redirect_to items_url(@item.parent)
    end
  end

  def complete
    if params[:completed_at].present?
      @item.update completed_at: params[:completed_at]
      current_user.log_action "checked item #{@item.id}"
    else
      @item.update completed_at: nil, archived: false
      current_user.log_action "unchecked item #{@item.id}"
    end

    if request.xhr?
      render json: @item
    else
      redirect_to items_url(@item.parent, anchor: "item-#{@item.id}")
    end
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

  def cleanup
    items = @item.present? ? @item.children : current_user.items
    items.completed.not_archived.update_all archived: true

    if request.xhr?
      head :ok
    else
      redirect_to items_path(@item)
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
    if @item.present? && @item.persisted? && !@item.root?
      @parent_items = @item.ancestors.not_archived.order(:ancestry)
    end
  end

  def item_params
    params.require(:item).permit(:name, :parent_id, :completed, :color)
  end

end
