function tryExcept(try, catch, finally)
    local status, exception = pcall(try)
    if not status and catch then
        catch(exception)
    end
    if finally then
        finally()
    end
end

