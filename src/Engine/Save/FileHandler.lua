local FileHandle = {}

function FileHandle:writeEncryptedFile(filename, data)
    love.filesystem.write(filename, love.data.compress("data", "gzip", data, 9))
end

function FileHandle:readEncryptedFile(filename)
    return love.data.decompress("string", "gzip", love.filesystem.read(filename))
end

return FileHandle
