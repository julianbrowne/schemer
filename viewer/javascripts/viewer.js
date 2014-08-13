
function Viewer() { 

    this.inspect = function(obj, html) { 
        var str = '', type, msg;
        var level = 0;
        var maxLevels = 10;
        if(maxLevels < 1) return 'Error: Object levels must be greater than 0';
        if(obj == null) return 'Error: Object was null';
        str += '<div class="group">';
        for(var field in obj) { 
            try { 
                type =  this.getType(obj[field]);
                if(((type == 'object')||(type == 'array')) && (obj[field] != null) && (level+1 < maxLevels)) { 
                    str += this.supplant(this.objectTemplate,{ type: type, field: field });
                    str += this.inspect(obj[field], maxLevels, level+1, html);
                }
                else { 
                    var f = (parseInt(field).toString() === field.toString()) ? '' : field;
                    var v = (obj[field]===null) ? 'null' : obj[field];
                    str += this.supplant(this.primitiveTemplate,{type: type, field: f, value: v});
                }

            }
            catch(err) { 
                str += '<li>Error: [' + field + '] : ' + err.toString() +'</li>';
            }
        }
        str += '</div>';
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

    this.objectTemplate = '\
        <div class="row {type}">\
            <div class="col-md-2">\
                <div class="object">\
                    <div class="label label-primary">\
                        {field}\
                        <span class="badge">{type}</span>\
                        <span class="glyphicon glyphicon-hand-right"></span>&nbsp;\
                    </div>\
                </div>\
            </div>\
        </div>';

    this.primitiveTemplate = '\
        <div class="row {type}">\
            <div class="col-md-3">\
                <div class="object">\
                    <div class="label label-info">\
                        {field}\
                        <span class="badge">{type}</span>\
                    </div>\
                </div>\
            </div>\
            <div class="col-md-8">\
                <div class="well well-sm">{value}</div>\
            </div>\
        </div>';

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

    this.supplant = function (templ, obj) { 
        return templ.replace(/{([^{}]*)}/g, function (a, b) { 
            var r = obj[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        });
    };

    this.get = function(url, callback) { 
        cacheBuster = (Math.random()*1000000);
        new this.Request('get', url + '?' + cacheBuster, callback).send();
    };

};
