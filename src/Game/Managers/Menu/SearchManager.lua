local SearchManager = {}
SearchManager.buttons = {}

function SearchManager:init(buttons)
    self.buttons = buttons
end

function SearchManager:searchForTags(curButton, split)
    for _, word in ipairs(split) do
        for _, chart in ipairs(curButton.children) do
            if string.find(string.lower(chart.data.tags or ""), string.lower(word)) then
                return true
            end
        end
    end
end

function SearchManager:searchForMapType(curButton, split)
    for _, word in ipairs(split) do
        for _, chart in ipairs(curButton.children) do
            if string.find(string.lower(chart.data.map_type), string.lower(word)) then
                return true
            end
        end
    end
end

function SearchManager:searchForTitle(curButton, split)
    for _, word in ipairs(split) do
        if string.find(string.lower(curButton.title), string.lower(word)) then
            return true
        end
    end
end

function SearchManager:doSearch(searchString)
    local results = {}

    for _, button in ipairs(self.buttons) do
        local split = searchString:split(" ")

        if self:searchForTags(button, split) or self:searchForTitle(button, split) or self:searchForMapType(button, split) then
            table.insert(results, button)
        end
    end

    if #results == 0 then
        for i, button in ipairs(self.buttons) do
            button.index = i
        end
        return self.buttons
    else
        -- we gotta redo the indexes now
        for i, button in ipairs(results) do
            button.index = i
        end
    end

    return results
end

return SearchManager