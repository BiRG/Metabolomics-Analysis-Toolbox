##############
#Changes to existing classes
#
#Will need to add keys_for_type and reorder_with methods to database
#
#Note: to use samples as objects with one key that can regenerate the
#object, we need to get rid of the SampleParams class and create
#ParameterizedSample and UnparameterizedSample classes with Sample as
#an abstract base-class.  This can be done without too much pain by
#leaving the sample_params objects in the database and then once
#referential integrity is checked, we can construct the sample
#subclasses.  The current Sample and SampleParams classes can be
#renamed FileFormatSample and FileFormatSampleParams.


class UnimplementedBaseMethod(Exception): pass

#Note keys should compare different when they come from different
#databases
class Key:
    def obj():
        raise UnimplementedBaseMethod

class PeakKey:
    def PeakKey(database, sample_id, peak_id):
        database = database
        sample_id = sample_id
        peak_id = peak_id

    def obj():
        return database.get_peak(sample_id,peak_id)

class PeakGroupKey:
    def PeakGroupKey(database, peak_group_id):
        database = database
        peak_group_id = peak_group_id

    def obj():
        #Note that this function will return a peak_group object for
        #any id since all peak_groups are assumed to exist
        return database.get_peak_group(peak_group_id)

class SampleKey:
    def SampleKey(database, sample_id):
        database = database
        sample_id = sample_id

    def obj():
        return database.get_sample(sample_id)

class ParamStatisticsKey:
    #Note that there can never be more than 1 ParamStatistics object
    #in a database, so the key giving it just needs to specify the
    #database
    def ParamStatisticsKey(datatbase):
        database = database
        
    def obj():
        return database.get_param_stats()


class KeyRelation(SetOfOrderedPairs):
    def project_first(): pass  #Trivial implementation

    def project_second(): pass #Trivial implementation

#TODO: write ObjectType class

#TODO: write MappingList class and iterator

#TODO: write have_same_non_key_parameters function

def equivalent_db(db1_orig, db2_orig):
    o1 = Ordering(db1)
    db1 = db1_orig
    db1.reorder_with(o1)

    o2 = Ordering(db2)
    db2 = db2_orig
    db2.reorder_with(o2)
    
    k1 = Set()
    k2 = Set()
    
    r = KeyRelation()

    for ot in ObjectType(param_stats, human_verified_peak, unverified_peak, 
                         unknown_peak, 
                         parameterized_sample, unparameterized_sample,
                         detected_peak_group, parameterized_peak_group,
                         peak_group):

        db1_keys = db1.keys_for_type(ot);
        db2_keys = db2.keys_for_type(ot);

        k1.add(db1_keys)
        k2.add(db2_keys)
        
        candidates = all_pairs(db1_keys, db2_keys)

        for c in candidates:
            if(have_same_non_key_parameters(c.first(), c.second())):
                r.add(c)

        if(r.project_first() != k1):
            return false
        if(r.project_second() != k2):
            return false

    maps = MappingList(r)
    cur = maps.begin()
    while(cur != maps.end()):
        if(cur.project_first() != k1):
            ++cur
            continue
        if(cur.project_second() != k2):
            ++cur
            continue

        #Check for two keys mapping to same value
        seen = Set()
        bad_mapping = False
        for k in k1:
            if(seen.contains(cur(k))):
                bad_mapping = True
                break
            else:
                seen.add(cur(k))
        if(bad_mapping):
            ++cur
            continue

        #Check for equivalence under the mapping and ordering
        for k in k1:
            obj1 = k.obj()
            obj2 = cur(k).obj()
            if(obj1.type() != obj2.type()):
                bad_mapping = True
                break
            elif(obj1.params() != obj2.params()):
                bad_mapping = True
                break                
            elif(cur(obj1.foreign_keys(db1)) != obj2.foreign_keys(db2)):
                bad_mapping = True
                break
        if(not bad_mapping):
            return true
        ++cur

    return false
