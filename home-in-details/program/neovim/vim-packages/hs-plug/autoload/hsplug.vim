let s:registered = []
function! hsplug#register(workingDirectory, exe_rel_path, args, specs)
    let l:FullPath = a:workingDirectory . "/" . a:exe_rel_path
    let l:Factory = function('hsplug#factory'
                \ , [ { 'cwd': a:workingDirectory
                \     , 'path': l:FullPath
                \     , 'args': a:args
                \     }
                \   ])
    call remote#host#Register(l:FullPath, '*', l:Factory)
    call s:RegisterSpecs(l:FullPath, a:specs)
endfunction

function! hsplug#factory(param, host_info)
    return jobstart( [ a:param.path ] + a:param.args
                \  , { 'cwd': a:param.cwd
                \    , 'rpc': v:true
                \    }
                \  )
endfunction

function! s:RegisterSpecs(path, specs) abort
    for path in s:registered
        if path == a:path
            throw 'Plugin "'.a:path.'" is already registered'
        endif
    endfor

    call add(s:registered, a:path)

    if remote#host#IsRunning(a:path)
        " For now we won't allow registration of plugins when the host is already
        " running.
        throw 'Host "'.a:path.'" is already running'
    endif

    for spec in a:specs
        let type = spec.type
        let name = spec.name
        let sync = spec.sync
        let opts = spec.opts
        let rpc_method = name
        if type == 'command'
            let rpc_method .= ':command'
            call remote#define#CommandOnHost(a:path, rpc_method, sync, name, opts)
            " elseif type == 'autocmd'
            "   " Since multiple handlers can be attached to the same autocmd event by a
            "   " single plugin, we need a way to uniquely identify the rpc method to
            "   " call.  The solution is to append the autocmd pattern to the method
            "   " name(This still has a limit: one handler per event/pattern combo, but
            "   " there's no need to allow plugins define multiple handlers in that case)
            "   let rpc_method .= ':autocmd:'.name.':'.get(opts, 'pattern', '*')
            "   call remote#define#AutocmdOnHost(a:host, rpc_method, sync, name, opts)
        elseif type == 'function'
            let rpc_method .= ':function'
            call remote#define#FunctionOnHost(a:path, rpc_method, sync, name, opts)
        else
            echoerr 'Invalid declaration type: '.type
        endif
    endfor
endfunction
