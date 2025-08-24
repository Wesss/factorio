-- local util = require("util")
local inspect = require("src.util.inspect")
-- local table = require("__flib__/table")

-- Represents an item and a quantity of it
local LineItem = {}
LineItem.__index = LineItem

function LineItem:new(itemName, amount)
    local instance = {}
    setmetatable(instance, LineItem)

    instance.itemName = itemName
    instance.amount = amount
    instance.fulfilled = 0

    return instance
end

function LineItem:remaining()
    return self.amount - self.fulfilled
end

-- Given another line item representing items for this to take, take and fulfil as much as possible
-- ex. if both line items are the same item type, fulfills both equal to the minimum amount remaining.
function LineItem:fulfill(lineItemOther)
    if (lineItemOther.itemName ~= self.itemName) then
        return
    end
    local remaining = self:remaining()
    if (remaining == 0) then
        return
    end
    local otherRemaining = lineItemOther:remaining()
    if (otherRemaining == 0) then
        return
    end

    local min = math.min(remaining, otherRemaining)
    self.fulfilled = self.fulfilled + min
    otherRemaining.fulfilled = otherRemaining.fulfilled + min
end

-- Represents a batch of items that need to be filled to progress science
local Order = {}
Order.__index = Order

function Order:new()
    local instance = {}
    setmetatable(instance, Order)

    instance.lineItems = {}

    return instance
end

-- Returns the queue of orders (first order is current order to fill).
-- Removes any fulfilled orders and replaces with new ones.
function Order.getOrders()
    -- TODO WESD load orders from storage
    local queue = {}
    local order = Order:new()
    table.insert(queue, order)
    -- TODO WESD implement actual order generation
    local lineItem = LineItem:new("iron-plate", 100)
    table.insert(order.lineItems, lineItem)

    return queue
end

-- persists the given order queue in storage
function Order.persist(orders)
    -- TODO WESD persist orders to storage
    -- TODO WESD make the queue its own class?
end

return Order, LineItem