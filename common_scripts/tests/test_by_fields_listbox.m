function test_suite = test_by_fields_listbox%#ok<STOUT>
%matlab_xUnit tests excercising by_fields_listbox
%
% Usage:
%   runtests by_fields_listbox
initTestSuite;

function testWithDuplicates %#ok<DEFNU>
% Tests whether correct projection is achieved when there are duplicates in
% the contents of the selected fields

c.foo=[1,100,10,100,2];
c.bar={'human','rat','rat','rat','human'};
c.baz=[1,2,3,4,5];
[sorted_fields_str,group_by_inxs,inxs,collection]=by_fields_listbox(c, {'foo','bar'});
assertEqual(sorted_fields_str, {'1, human'    '10, rat'    '100, rat'    '2, human'});
assertEqual(group_by_inxs, { [1]    [2, 4]    [3]    [5] });
assertEqual(inxs, [1     3     2     4]);
assertEqual(c.foo, collection.foo);
assertEqual(c.bar, collection.bar);
assertEqual(c.baz, collection.baz);
assertEqual(collection.value,  {'1, human'  '100, rat'  '10, rat'  '100, rat'  '2, human'});

function testWithoutDuplicates %#ok<DEFNU>
% Tests whether correct projection is achieved when there are no duplicates in
% the contents of the selected fields

c.foo=[1,100,10,100,2];
c.bar={'human','rat','rat','rat','human'};
c.baz=[1,2,3,4,5];
[sorted_fields_str,group_by_inxs,inxs,collection]=by_fields_listbox(c, {'foo','baz'});
assertEqual(sorted_fields_str, { '1, 1'    '10, 3'    '100, 2'    '100, 4'    '2, 5'});
assertEqual(group_by_inxs, { 1    2    3    4    5 });
assertEqual(inxs, [ 1     3     2     4     5]);
assertEqual(c.foo, collection.foo);
assertEqual(c.bar, collection.bar);
assertEqual(c.baz, collection.baz);
assertEqual(collection.value, {'1, 1'  '100, 2'  '10, 3'  '100, 4'  '2, 5'});

function testWithEmptySlice %#ok<DEFNU>
% Tests whether correct projection is achieved when the list of fields is
% empty

c.foo=[1,100,10,100,2];
c.bar={'human','rat','rat','rat','human'};
c.baz=[1,2,3,4,5];
[sorted_fields_str,group_by_inxs,inxs,collection]=by_fields_listbox(c, {});
assertEqual(sorted_fields_str, cell(0,1));
assertEqual(group_by_inxs, {});
assertEqual(inxs, zeros(0,1));
assertEqual(c.foo, collection.foo);
assertEqual(c.bar, collection.bar);
assertEqual(c.baz, collection.baz);
assertEqual(collection.value, {});

function testWithSingleField %#ok<DEFNU>
% Tests whether correct projection is achieved when there is only one field

c.foo=[1,100,10,100,2];
c.bar={'human','rat','rat','rat','human'};
c.baz=[1,2,3,4,5];
[sorted_fields_str,group_by_inxs,inxs,collection]=by_fields_listbox(c, {'bar'});
assertEqual(sorted_fields_str, {'human'    'rat'});
assertEqual(group_by_inxs, { [1,5]    [2, 3, 4]});
assertEqual(inxs, [1,2]);
assertEqual(c.foo, collection.foo);
assertEqual(c.bar, collection.bar);
assertEqual(c.baz, collection.baz);
assertEqual(collection.value,  {'human'  'rat'  'rat'  'rat'  'human'});

