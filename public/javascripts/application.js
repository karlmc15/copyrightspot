// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function reset_input_default_value(id, value){
	i = $(id);
	if (i.value.length == 0){
		i.value = value;
	}
}

function clear_input_default_value(id, value){
	i = $(id);
	if (i.value == value){
		i.value = '';
	}
}