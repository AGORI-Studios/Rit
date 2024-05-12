local SearchAlgorithm = {}

SearchAlgorithm.allSongButtons = {}

function SearchAlgorithm:setUpSongButtons(songButtons)
    self.allSongButtons = songButtons
end

function SearchAlgorithm:searchForTags(curButton, split)
    for i, tag in ipairs(curButton.tags) do
        local tags = {}
        for _, word in ipairs(tag:split(" ")) do
            table.insert(tags, string.lower(word))
        end
        if table.contains(tags, string.lower(split[1])) then
            return true
        end
    end
end

function SearchAlgorithm:searchForTitle(curButton, split)
    for i, word in ipairs(split) do
        if string.find(string.lower(curButton.name), string.lower(word)) then
            return true
        end
    end
end

function SearchAlgorithm:searchForChartType(curButton, split)
    for i, word in ipairs(split) do
        if string.find(string.lower(curButton.type), string.lower(word)) then
            return true
        end
    end
end

function SearchAlgorithm:doSearch(searchString)
    local searchResults = {}

    for i, button in ipairs(self.allSongButtons) do
        local split = searchString:split(" ")

        if self:searchForTags(button, split) or self:searchForTitle(button, split) or self:searchForChartType(button, split) then
            table.insert(searchResults, button)
        end
    end

    return searchResults
end

return SearchAlgorithm