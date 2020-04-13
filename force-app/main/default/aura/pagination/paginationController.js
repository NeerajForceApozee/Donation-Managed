({
doInit : function(component, event, helper) {
var next = false;
var prev = false;
helper.getAccountListWithPaging(component,next,prev);
},
 
OnNext:function(component,event,helper)
{
var next = true;
var prev = false;
var offset = component.get("v.offset");
helper.getAccountListWithPaging(component,next,prev,offset);
},
OnPrevious:function(component,event,helper)
{
var next = false;
var prev = true;
var offset = component.get("v.offset");
helper.getAccountListWithPaging(component,next,prev,offset);
}
})