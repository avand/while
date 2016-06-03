class ItemsController < ApplicationController

  before_action :require_current_user
  before_action :set_item, only: [
    :new, :edit, :create, :update, :destroy, :complete, :adopt, :cleanup]
  before_action :set_parent_items, only: [:new, :edit, :create, :update]
  before_action :validate_hashid

  def index
    if params[:hashid].present?
      @parent = Item.find_by_hashid params[:hashid]
      @root = @parent.root
      @items = @parent.children

      cookies[:last_viewed_item_hashid] = {
        value: @parent.hashid,
        expires: 1.week.from_now
      }
    else
      last_viewed_item_hashid = cookies.delete :last_viewed_item_hashid

      if last_viewed_item_hashid.present? && request.referer.blank?
        redirect_to items_path(last_viewed_item_hashid)
        return
      end

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
      @ancestors += @parent.ancestors.map do |item|
        [item.name, items_path(item), item.hashid]
      end

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
    params[:hashids].split(",").each_with_index do |id, i|
      Item.find_by_hashid(id).update order: i
    end
  end

  def adopt
    child_item = Item.find_by_hashid(params[:child_hashid])

    child_item.parent = @item
    child_item.make_last
    child_item.save

    if @item
      render partial: "progress_bar", object: @item, as: "item"
    else
      head :ok
    end
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
    if params[:hashid].present?
      @item = current_user.items.find_by_hashid params[:hashid]
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

  def validate_hashid
    if params[:hashid].present? && params[:hashid] =~ /\A\d+\z/
      flash[:notice] = \
        "For your privacy, the URLs for all your lists have changed and no " +
        "longer include a sequential (and easily guessable) ID. Any existing" +
        "links to your lists will no longer work but you shouldn’t " +
        "experience any other issues."

      redirect_to root_path
    end
  end

end
