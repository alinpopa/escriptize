-module(escriptize).
-export([main/1]).

main([]) ->
    io:format("./escriptize output~n"),
    halt(1);

main([OutputPath] = _Args) ->
    Main = OutputPath,
    % We need specific paths in the ZIP file:
    % The main application needs, e.g.,
    %   {"hello/ebin/hello.beam", "ebin/hello.beam"}
    InputPaths0 = [{filename:join([Main, F]), F}
                   || F <- filelib:wildcard("ebin/*.beam")],
    % Then we need to add the deps, e.g.,
    %   {"mochijson2/ebin/mochijson.beam", "deps/mochijson2/ebin/mochijson2.beam"}
    Deps = filelib:wildcard("*", "deps"),
    InputPaths1 = lists:flatmap(
                   fun(Dep) ->
                           DepDir = filename:join("deps", Dep),
                           [{filename:join(Dep, F), filename:join(DepDir, F)}
                            || F <- filelib:wildcard("ebin/*.beam", DepDir)]
                   end, Deps),
    InputPaths = InputPaths0 ++ InputPaths1,
    io:format("Creating ~s with ~p~n", [OutputPath, InputPaths]),
    {ok, ZipBin} = create_zip(InputPaths),

    EmuArgs = io_lib:format("-pa ~s/ebin", [Main]),
    Sections = [shebang,
                {emu_args, EmuArgs},
                {archive, ZipBin}],
    {ok, Bin} = escript:create('binary', Sections),
    ok = file:write_file(OutputPath, Bin).

create_zip(InputPaths) ->
    Files = lists:map(fun({Path, InputPath}) ->
                              {ok, Bin} = file:read_file(InputPath),
                              {Path, Bin}
                      end, InputPaths),
    {ok, {"mem", ZipBin}} = zip:create("mem", Files, [memory]),
    {ok, ZipBin}.