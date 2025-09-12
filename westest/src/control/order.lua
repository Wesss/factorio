-- local util = require("util")
local marketValue = require("src.control.market-value")
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

-- returns a table representation of this that can be written to storage. does not contain metatable (cant call class functions)
function LineItem:toStorageFormat()
    return {
        itemName = self.itemName,
        amount = self.amount,
        fulfilled = self.fulfilled
    }
end

-- returns an instance of this, initialized from its storage table
function LineItem.fromStorageFormat(storageLineItem)
    local lineItem = LineItem:new()

    if storageLineItem ~= nil then
        lineItem.itemName = storageLineItem.itemName
        lineItem.amount = storageLineItem.amount
        lineItem.fulfilled = storageLineItem.fulfilled
    end

    return lineItem
end

function LineItem:remaining()
    return self.amount - self.fulfilled
end

function LineItem:isFulfilled()
    return self.fulfilled >= self.amount
end

-- fulfil the given line item as much as possible using the given inventory
function LineItem:fulfill(inventory, resarchValueRemaining)
    if (resarchValueRemaining <= 0) then
        return 0
    end
    local remaining = self:remaining()
    if (remaining == 0) then
        return 0
    end
    local inventoryCnt = inventory.get_item_count(self.itemName)
    if (inventoryCnt == 0) then
        return 0
    end
    local marketValue = marketValue.GetValue(self.itemName)
    -- round up so that its possible to reach 100% completion
    local researchCntMax = math.ceil(resarchValueRemaining / marketValue)
    local limitCnt = math.min(remaining, researchCntMax)

    local sellCount = math.min(inventoryCnt, limitCnt)
    local itemizedValue = sellCount * marketValue
    game.print("wesd flag2 LineItem:fulfill itemname=" .. self.itemName .. " amount=" .. self.amount .. " fulfilled=" .. self.fulfilled .. " remaining=" .. remaining .. " researchCntMax= " .. researchCntMax .. " toRemoveCnt=" .. sellCount .. " itemizedValue=" .. itemizedValue)

    inventory.remove({name = self.itemName, count = sellCount})
    self.fulfilled = self.fulfilled + sellCount
    return itemizedValue
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

-- returns a table representation of this that can be written to storage. does not contain metatable (cant call class functions)
function Order:toStorageFormat()
    local storageLineItems = {}
    for _, lineItem in pairs(self.lineItems) do
        table.insert(storageLineItems, lineItem:toStorageFormat())
    end
    return {
        lineItems = storageLineItems
    }
end

-- returns an instance of this, initialized from its storage table
function Order.fromStorageFormat(storageOrder)
    local order = Order:new()

    if storageOrder ~= nil then
        order.lineItems = {}
        for _, storageLineItem in pairs(storageOrder.lineItems) do
            table.insert(order.lineItems, LineItem.fromStorageFormat(storageLineItem))
        end
    end

    return order
end

-- fulfils this order as much as possible with the given items
function Order:fulfill(inventory, researchValueRemaining)
    local totalValueFulfilled = 0
    for a, lineItem in pairs(self.lineItems) do
        local valueFulfilled = lineItem:fulfill(inventory, researchValueRemaining)
        totalValueFulfilled = totalValueFulfilled + valueFulfilled
        researchValueRemaining = math.max(0, researchValueRemaining - valueFulfilled)
    end
    return totalValueFulfilled
end

-- returns true if this order needs no more items. false if more items can still be fulfilled.
function Order:isFulfilled()
    for _, lineItem in pairs(self.lineItems) do
        if not lineItem:isFulfilled() then
            return false
        end
    end
    return true
end

return {
    Order = Order,
    LineItem = LineItem
}