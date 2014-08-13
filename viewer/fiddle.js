function Viewer() { 

    this.inspect = function(obj, html) { 
        var str = '', type, msg;
        var level = 0;
        var maxLevels = 10;
        if(maxLevels < 1) return 'Error: Object levels must be greater than 0';
        if(obj == null) return 'Error: Object was null';
        str += '<ul>';
        for(var field in obj) { 
            try { 
                type =  this.getType(obj[field]);
                if(((type == 'object')||(type == 'array')) && (obj[field] != null) && (level+1 < maxLevels)) {
                    str += '<li class="' + type + '">' + field + '(' + type + ')</li>';                    
                    str += this.inspect(obj[field], maxLevels, level+1, html);
                }
                else { 
                    str += '<li class="' + type + ' key_value">';
                    if(parseInt(field).toString() !== field.toString()) { 
                        str += '<span class="key">' + field + '</span>';
                    }
                    str += '<span class="value">' + ((obj[field]==null)?(': <b>null</b>'):(obj[field])) + '</span>';
                    str += '</li>';
                }

            }
            catch(err) { 
                str += '<li>Error: [' + field + '] : ' + err.toString() +'</li>';
            }
        }
        str += '</ul>';
        if(!html) str = str.replace(/<.+?>/g,'');
        return str;
    };

    this.getType = function(obj) { 
        var s = typeof obj;
        if (s === 'object') { 
            if (obj) { 
                if (typeof obj.length === 'number' && !(obj.propertyIsEnumerable('length')) && typeof obj.splice === 'function') { 
                    return 'array';
                }
            }
            else
                return 'null';
        }
        return s;
    };

    this.Request = function(method, url, callback) { 
        var request = this;
        this.body = '';
        this.xmlhttp = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
        this.xmlhttp.onreadystatechange=function() { 
            if (request.xmlhttp.readyState==4) { 
                if(request.xmlhttp.status>=200&&request.xmlhttp.status<=299)
                    callback(request.xmlhttp.responseText);
                else { 
                    console.log(request.xmlhttp.status);
                    console.log(request.xmlhttp.responseText);
                }
            }
        };
        this.headers = { 
            "Content-type": "application/json"
        }
        this.send = function() { 
            request.xmlhttp.open(method.toUpperCase(), url, true);
            Object.keys(request.headers).forEach(function(header) { 
                request.xmlhttp.setRequestHeader(header,request.headers[header]);
            });
            request.xmlhttp.send();
        }
    };

    this.get = function(url, callback) { 
        new this.Request('get', url, callback).send();
    };

};

var json = '{"schema":{"$schema":"http://json-schema.org/draft-03/schema#","description":"Generated from schemer with shasum b194a16eda7c06a0f609e58a4f4da6ff40c2613c","type":"object","required":true,"properties":{"hubId":{"type":"integer","required":true},"time":{"type":"string","required":true},"metrics":{"type":["null","array"],"required":true,"minItems":1,"uniqueItems":true,"items":{"type":"object","required":false,"properties":{"name":{"type":"string","required":true},"value":{"type":"number","required":true}}}},"statuses":{"type":["null","array"],"required":true,"minItems":1,"uniqueItems":true,"items":{"type":"object","required":false,"properties":{"name":{"type":"string","required":true},"value":{"type":"string","required":true}}}}}},"values":{"hubId":[202745398576986901376091745],"metrics":[null],"metrics[n].name":["Hot_water_outlet_temperature","Actual_Power","Hot_water_flow_sensor_(turbine)","System_time","CH_pump_modulation","Supply_temperature_(primary_flow_temperature)","Supply_temperature_(primary_flow_temperature)_setpoint","Working_time_total_of_the_burner","Number_of_burner_starts","Hot_water_temperature_setpoint"],"metrics[n].value":[25.4,38,84,96,74,37,5.6,30,3331275,100,0,25.6,44,59.2,65,75,32,52726,54,66,34,50,748209,124425,51],"statuses":[null],"statuses[n].name":["Relay_status:_Ignition","Relay_status:_CH_pump","Relay_status:_Fan","Relay status:_internal_3-way-valve","Relay_status:_Gasvalve","Relay_status:_HW_circulation_pump","Operating_status:_Boiler_in_heat_up_phase","Operating_status:_Error_Blocking","Operating_status:_Hot_water_active","Operating_status:_Maintenance_request","Operating_status:_Central_heating_active","Operating_status:_Flame","Operating_status:_Error_Locking","Central_heating_blocked","(Primary)_Return_temperature","System_water_pressure"],"statuses[n].value":["Off","Hot_water","On","No","Yes","Central_heating","Sensor_connection_OPEN","Not_available"],"time":["2014-03-07T12:00:26Z","2014-03-07T12:00:27Z","2014-03-07T12:00:28Z","2014-03-07T12:00:29Z","2014-03-07T12:00:30Z","2014-03-07T12:00:31Z"]}}';

$(function() { 

    var v = new Viewer();

    var html = v.inspect(JSON.parse(json), true);
    $('#navigator').html(html);
    $('.object, .array').each(function() { 
        if($(this).next().is(":visible"))
            $(this).next().toggle();
    });
    $('.object, .array').click(function(e) { $(this).next().toggle(); });

});
