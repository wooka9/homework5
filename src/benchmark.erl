-module(benchmark).
-export([runner_ets/2, fill_proplist/1, fill_map/2, runner_static/3]).

runner_ets(0, _) ->
	finish;
runner_ets(N, RunList) ->
	[M, F, A] = RunList,
	[Storage, KeyValue] = A,
	case KeyValue of
		"generate" ->
			timer:tc(M, F, [Storage, {integer_to_list(N), N} ]);
		_ ->
			timer:tc(M, F, A)
	end,
	runner_ets(N-1, RunList).

% ets:new(table, [named_table, public]).
% ets:new(table, [named_table, public, duplicate_bag]).
% EI = [ets, insert_new, [table, "generate" ] ].
% EL = [ets, lookup, [table, "500000"] ].
% timer:tc(benchmark, runner_ets, [1000000, EI]). first: 862418 / repeat: 535436
% timer:tc(benchmark, runner_ets, [1000000, EL]). 304590
% ets:info(table,memory).

% dets:open_file("filename", []).
% dets:open_file("filename", [duplicate_bag]).
% DI = [dets, insert_new, ["filename", "generate" ] ].
% DL = [dets, lookup, ["filename", "500000"] ].
% timer:tc(benchmark, runner_ets, [1000000, DI]). 45107925
% timer:tc(benchmark, runner_ets, [1000000, DL]). 8925057
% dets:info("filename", size).

fill_map(0, Map) ->
	Map;
fill_map(N, Map) ->
	fill_map(N-1, maps:put(integer_to_list(N), N, Map)).

fill_proplist(0) ->
	[];
fill_proplist(N) ->
	[ {integer_to_list(N), N} | fill_proplist(N-1) ].

runner_static(0, _, _) ->
	finish;
runner_static(N, RunList, Storage) ->
	[M, F, A] = RunList,
	timer:tc(M, F, [A | [Storage] ]),
	runner_static(N-1, RunList, Storage).

% Map = benchmark:fill_map(1000000, #{}).
% MF = [maps, find, ["500000"]].
% timer:tc(benchmark, runner_static, [1000000, MF, Map]). 268044

% PropList = benchmark:fill_proplist(1000000).
% PL = [proplists, lookup, ["500000"] ].
% timer:tc(benchmark, runner_static, [1000, PL, PropList]). 15001137
% timer:tc(benchmark, runner_static, [1000000, PL, PropList]). 15001137'000
