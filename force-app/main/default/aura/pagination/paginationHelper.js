({
getAccountListWithPaging: function(component,next,prev,offset) {
offset = offset || 0;
var action = component.get('c.GetAccountWithPaging');
action.setParams({
"next" : next,
"prev" : prev,
"off" : offset
})
var self = this;
action.setCallback(this, function(actionResult) {
var result=actionResult.getReturnValue(); 
component.set('v.offset',result.offst);
component.set('v.next',result.hasnext);
component.set('v.prev',result.hasprev);
component.set('v.lstAccount', result.lstAccount);
});
$A.enqueueAction(action);
}
})