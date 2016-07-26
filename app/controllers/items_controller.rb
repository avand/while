class ItemsController < ApplicationController

  before_action :require_current_user
  before_action :redirect_to_last_viewed_item, only: :index

  def index
    @parent = get_item
    @root = get_root(@parent)
    @items = get_items(@parent).not_completed.order(:order, :created_at)
    @ancestors = get_ancestors(@parent)

    if @parent.present?
      cookies[:last_viewed_item_hashid] = {
        value: @parent.hashid,
        expires: 1.week.from_now
      }
    end
  end

  def history
    @history = get_history(get_items(get_item))

    render layout: false
  end

  def new
    @item = build_item
  end

  def edit
    @item = get_item
    @parents = get_parents(@item)
  end

  def create
    @item = build_item

    if @item.save
      current_user.log_action "created item #{@item.id}"
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :new
    end
  end

  def update
    @item = get_item
    @parents = get_parents(@item)

    if @item.update(item_params)
      current_user.log_action "updated item #{@item.id}"
      redirect_to items_path(@item.parent, anchor: "item-#{@item.id}")
    else
      render :edit
    end
  end

  def destroy
    @item = get_item

    @item.update deleted_at: params[:deleted_at]

    if request.xhr?
      render json: @item
    else
      redirect_to items_url(@item.parent)
    end
  end

  def complete
    item = get_item

    if params[:completed_at].present?
      item.update completed_at: params[:completed_at]

      @history = get_history(get_items(item.parent))

      render :history, layout: false

      current_user.log_action "checked item #{item.id}"
    else
      item.make_last
      item.update completed_at: nil

      redirect_to items_url(item.parent, anchor: "item-#{item.id}")

      current_user.log_action "unchecked item #{item.id}"
    end
  end

  def reorder
    params[:hashids].split(",").each_with_index do |id, i|
      Item.find_by_hashid(id).update order: i
    end
  end

  def adopt
    child_item = Item.find_by_hashid(params[:child_hashid])

    child_item.parent = get_item
    child_item.make_last
    child_item.save

    if child_item.parent.present?
      render partial: "progress_bar", object: child_item.parent, as: "item"
    else
      head :ok
    end
  end

private

  def get_item
    params[:hashid].present? ? Item.find_by_hashid(params[:hashid]) : nil
  end

  def get_root(item)
    item.try(:root)
  end

  def get_items(item)
    (item.try(:children) || current_user.items.roots).not_deleted
  end

  def get_ancestors(item)
    ancestors = [["While", items_path]]

    if item.present?
      ancestors += item.ancestors.map do |item|
        [item.name, items_path(item), item.hashid]
      end

      ancestors << [item.name, items_path(item)]
    end

    ancestors
  end

  def get_parents(item)
    item.ancestors.not_completed.order(:ancestry)
  end

  def get_history(items)
    items.completed.order("completed_at desc").group_by do |item|
      item.completed_at.to_date
    end
  end

  def build_item
    current_user.items.new item_params
  end

  def item_params
    params.require(:item).permit(:name, :parent_id, :completed, :color)
  end

  def redirect_to_last_viewed_item
    last_viewed_item_hashid = cookies.delete :last_viewed_item_hashid

    if last_viewed_item_hashid.present? && request.referer.blank?
      redirect_to items_path(last_viewed_item_hashid)
    end
  end

end
