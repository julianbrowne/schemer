
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
                    str += '<div class="row ' + type + '">';
                    str += '<div class="col-md-2">';
                    str += '<h3><div class="label label-primary">&nbsp;'
                    str += field;
                    str += '&nbsp;<span class="badge">' + type + '</span>&nbsp;';
                    str += '<span class="glyphicon glyphicon-hand-right"></span>';
                    str += '</div></h3>';
                    str += '</div>';
                    str += '</div>';
                    str += this.inspect(obj[field], maxLevels, level+1, html);

                    //str += '<li class="' + type + '">' + field + '(' + type + ')</li>';                  
                }
                else { 
                    str += '<div class="row ' + type + '">';
                    str += '<div class="col-md-3">';
                    str += '<div class="primitive">';
                    str += '<div class="label label-info">&nbsp;';
                    if(parseInt(field).toString() !== field.toString()) str += field
                    str += '&nbsp;<span class="badge">' + type + '</span>&nbsp;';
                    str += '</div>&nbsp;';
                    str += '</div>';
                    str += '</div>';
                    str += '<div class="col-md-8">';
                    str += '<div class="well well-sm">' + ((obj[field]==null)?(': <b>null</b>'):(obj[field])) + '</div>';
                    str += '</div>';
                    str += '</div>';
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
