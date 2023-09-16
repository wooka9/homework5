-module(my_cache).
-export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).

create(TableName) ->
	ets:new(TableName, [named_table, public]),
	ok.

insert(TableName, Key, Value) ->
	ets:insert(TableName, {Key, Value}),
	ok.

insert(TableName, Key, Value, Expire) ->
	ExpireTime = erlang:system_time(seconds) + Expire,
	ets:insert(TableName, {Key, Value, ExpireTime}),
	ok.

lookup(TableName, Key) ->
	TimeNow = erlang:system_time(seconds),
	case ets:lookup(TableName, Key) of
		[{Key, Value}] ->
			Value;
		[{Key, Value, Expire}] when Expire >= TimeNow ->
			Value;
		_ -> undefined
	end.

delete_obsolete(TableName) ->
	TimeNow = erlang:system_time(seconds),
	ets:select_delete(TableName, [ { {'$1', '$2', '$3'}, [{'<', '$3', TimeNow}], [true] } ] ),
	ok.
