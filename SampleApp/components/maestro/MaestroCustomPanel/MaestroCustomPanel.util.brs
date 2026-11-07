' Helpers for MaestroCustomPanel, on Roku's own APIs only, so the folder compiles in any
' channel. A subclass may use them too. The mcp prefix is reserved: the base's scripts and
' the subclass's share one scope, so a subclass function of the same name would replace it.

' @param {dynamic} value
' @return {boolean} invalid or uninitialized
function mcpIsNull(value as dynamic) as boolean
    valueType = type(value)
    return valueType = "<uninitialized>" or valueType = "Invalid" or valueType = "roInvalid"
end function

' @param {dynamic} value
' @return {boolean} the boolean true (not "true", not 1)
function mcpIsTrue(value as dynamic) as boolean
    valueType = type(value)
    return (valueType = "Boolean" or valueType = "roBoolean") and value = true
end function

' @param {dynamic} value
' @return {boolean}
function mcpIsString(value as dynamic) as boolean
    valueType = type(value)
    return valueType = "String" or valueType = "roString"
end function

' @param {dynamic} value
' @return {boolean} a string with at least one character
function mcpIsStringWithLength(value as dynamic) as boolean
    return mcpIsString(value) and Len(value) > 0
end function

' @param {dynamic} value
' @return {boolean}
function mcpIsAa(value as dynamic) as boolean
    return type(value) = "roAssociativeArray"
end function

' @param {dynamic} value
' @return {boolean} an integer or a float
function mcpIsNumber(value as dynamic) as boolean
    valueType = type(value)
    return valueType = "Integer" or valueType = "roInt" or valueType = "roInteger" or valueType = "LongInteger" or valueType = "roLongInteger" or valueType = "Float" or valueType = "roFloat" or valueType = "Double" or valueType = "roDouble"
end function

' Observes a node field in this component's scope; the callback is a function name.
'
' @param {roSGNode} node
' @param {string} field
' @param {string} callbackName
sub mcpObserve(node as object, field as string, callbackName as string)
    node.observeFieldScoped(field, callbackName)
end sub
