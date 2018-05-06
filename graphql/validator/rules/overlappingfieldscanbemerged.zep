namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Language\Printer;
use GraphQL\Type\Definition\CompositeType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\OutputType;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\PairSet;
use GraphQL\Utils\TypeInfo;
use GraphQL\Validator\ValidationContext;
class OverlappingFieldsCanBeMerged extends AbstractValidationRule
{
    static function fieldsConflictMessage(responseName, reason)
    {
        var reasonMessage;
    
        let reasonMessage =  self::reasonMessage(reason);
        return "Fields \"{responseName}\" conflict because {reasonMessage}. Use different aliases on the fields to fetch both if this was intentional.";
    }
    
    static function reasonMessage(reason)
    {
        var tmp, responseName, subReason, tmpListResponseNameSubReason, reasonMessage;
    
        if is_array(reason) {
            let tmpListResponseNameSubReason = tmp;
            let responseName = tmpListResponseNameSubReason[0];
            let subReason = tmpListResponseNameSubReason[1];
            let reasonMessage =  self::reasonMessage(subReason);
            let tmp =  array_map(new OverlappingFieldsCanBeMergedreasonMessageClosureOne(), reason);
            return implode(" and ", tmp);
        }
        return reason;
    }
    
    /**
     * A memoization for when two fragments are compared "between" each other for
     * conflicts. Two fragments may be compared many times, so memoizing this can
     * dramatically improve the performance of this validator.
     * @var PairSet
     */
    protected comparedFragmentPairs;
    /**
     * A cache for the "field map" and list of fragment names found in any given
     * selection set. Selection sets may be asked for this information multiple
     * times, so this improves the performance of this validator.
     *
     * @var \SplObjectStorage
     */
    protected cachedFieldsAndFragmentNames;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray41adf918fbc294ee129b95b701844802, conflicts, conflict, responseName, reason, fields1, fields2;
    
        let this->comparedFragmentPairs =  new PairSet();
        let this->cachedFieldsAndFragmentNames =  new \SplObjectStorage();
        let conflicts =  this->findConflictsWithinSelectionSet(context, context->getParentType(), selectionSet);
        let responseName = conflict[0][0];
        let reason = conflict[0][1];
        let fields1 = conflict[1];
        let fields2 = conflict[2];
        let tmpArray41adf918fbc294ee129b95b701844802 = let conflicts =  this->findConflictsWithinSelectionSet(context, context->getParentType(), selectionSet);
        let responseName = conflict[0][0];
        let reason = conflict[0][1];
        let fields1 = conflict[1];
        let fields2 = conflict[2];
        [NodeKind::SELECTION_SET : new OverlappingFieldsCanBeMergedgetVisitorClosureOne(context)];
        return tmpArray3cac4c087bd4860867074f0195aa42dc;
    }
    
    /**
     * Algorithm:
     *
     * Conflicts occur when two fields exist in a query which will produce the same
     * response name, but represent differing values, thus creating a conflict.
     * The algorithm below finds all conflicts via making a series of comparisons
     * between fields. In order to compare as few fields as possible, this makes
     * a series of comparisons "within" sets of fields and "between" sets of fields.
     *
     * Given any selection set, a collection produces both a set of fields by
     * also including all inline fragments, as well as a list of fragments
     * referenced by fragment spreads.
     *
     * A) Each selection set represented in the document first compares "within" its
     * collected set of fields, finding any conflicts between every pair of
     * overlapping fields.
     * Note: This is the *only time* that a the fields "within" a set are compared
     * to each other. After this only fields "between" sets are compared.
     *
     * B) Also, if any fragment is referenced in a selection set, then a
     * comparison is made "between" the original set of fields and the
     * referenced fragment.
     *
     * C) Also, if multiple fragments are referenced, then comparisons
     * are made "between" each referenced fragment.
     *
     * D) When comparing "between" a set of fields and a referenced fragment, first
     * a comparison is made between each field in the original set of fields and
     * each field in the the referenced set of fields.
     *
     * E) Also, if any fragment is referenced in the referenced selection set,
     * then a comparison is made "between" the original set of fields and the
     * referenced fragment (recursively referring to step D).
     *
     * F) When comparing "between" two fragments, first a comparison is made between
     * each field in the first referenced set of fields and each field in the the
     * second referenced set of fields.
     *
     * G) Also, any fragments referenced by the first must be compared to the
     * second, and any fragments referenced by the second must be compared to the
     * first (recursively referring to step F).
     *
     * H) When comparing two fields, if both have selection sets, then a comparison
     * is made "between" both selection sets, first comparing the set of fields in
     * the first selection set with the set of fields in the second.
     *
     * I) Also, if any fragment is referenced in either selection set, then a
     * comparison is made "between" the other set of fields and the
     * referenced fragment.
     *
     * J) Also, if two fragments are referenced in both selection sets, then a
     * comparison is made "between" the two fragments.
     *
     */
    /**
     * Find all conflicts found "within" a selection set, including those found
     * via spreading in fragments. Called when visiting each SelectionSet in the
     * GraphQL Document.
     *
     * @param ValidationContext $context
     * @param CompositeType $parentType
     * @param SelectionSetNode $selectionSet
     * @return array
     */
    protected function findConflictsWithinSelectionSet(<ValidationContext> context, parentType, <SelectionSetNode> selectionSet)
    {
        var fieldMap, fragmentNames, tmpListFieldMapFragmentNames, conflicts, fragmentNamesLength, comparedFragments, i, j;
    
        let tmpListFieldMapFragmentNames = this->getFieldsAndFragmentNames(context, parentType, selectionSet);
        let fieldMap = tmpListFieldMapFragmentNames[0];
        let fragmentNames = tmpListFieldMapFragmentNames[1];
        let conflicts =  [];
        // (A) Find find all conflicts "within" the fields of this selection set.
        // Note: this is the *only place* `collectConflictsWithin` is called.
        this->collectConflictsWithin(context, conflicts, fieldMap);
        let fragmentNamesLength =  count(fragmentNames);
        if fragmentNamesLength !== 0 {
            // (B) Then collect conflicts between these fields and those represented by
            // each spread fragment name found.
            let comparedFragments =  [];
            let i = 0;
            for i in range(0, fragmentNamesLength) {
                this->collectConflictsBetweenFieldsAndFragment(context, conflicts, comparedFragments, false, fieldMap, fragmentNames[i]);
                // (C) Then compare this fragment with all other fragments found in this
                // selection set to collect conflicts between fragments spread together.
                // This compares each item in the list of fragment names to every other item
                // in that same list (except for itself).
                let j =  i + 1;
                for j in range(i + 1, fragmentNamesLength) {
                    this->collectConflictsBetweenFragments(context, conflicts, false, fragmentNames[i], fragmentNames[j]);
                }
            }
        }
        return conflicts;
    }
    
    /**
     * Collect all conflicts found between a set of fields and a fragment reference
     * including via spreading in any nested fragments.
     *
     * @param ValidationContext $context
     * @param array $conflicts
     * @param array $comparedFragments
     * @param bool $areMutuallyExclusive
     * @param array $fieldMap
     * @param string $fragmentName
     */
    protected function collectConflictsBetweenFieldsAndFragment(<ValidationContext> context, array conflicts, array comparedFragments, bool areMutuallyExclusive, array fieldMap, string fragmentName)
    {
        var fragment, fieldMap2, fragmentNames2, tmpListFieldMap2FragmentNames2, fragmentNames2Length, i;
    
        if isset comparedFragments[fragmentName] {
            return;
        }
        let comparedFragments[fragmentName] = true;
        let fragment =  context->getFragment(fragmentName);
        if !(fragment) {
            return;
        }
        let tmpListFieldMap2FragmentNames2 = this->getReferencedFieldsAndFragmentNames(context, fragment);
        let fieldMap2 = tmpListFieldMap2FragmentNames2[0];
        let fragmentNames2 = tmpListFieldMap2FragmentNames2[1];
        if fieldMap === fieldMap2 {
            return;
        }
        // (D) First collect any conflicts between the provided collection of fields
        // and the collection of fields represented by the given fragment.
        this->collectConflictsBetween(context, conflicts, areMutuallyExclusive, fieldMap, fieldMap2);
        // (E) Then collect any conflicts between the provided collection of fields
        // and any fragment names found in the given fragment.
        let fragmentNames2Length =  count(fragmentNames2);
        let i = 0;
        for i in range(0, fragmentNames2Length) {
            this->collectConflictsBetweenFieldsAndFragment(context, conflicts, comparedFragments, areMutuallyExclusive, fieldMap, fragmentNames2[i]);
        }
    }
    
    /**
     * Collect all conflicts found between two fragments, including via spreading in
     * any nested fragments.
     *
     * @param ValidationContext $context
     * @param array $conflicts
     * @param bool $areMutuallyExclusive
     * @param string $fragmentName1
     * @param string $fragmentName2
     */
    protected function collectConflictsBetweenFragments(<ValidationContext> context, array conflicts, bool areMutuallyExclusive, string fragmentName1, string fragmentName2)
    {
        var fragment1, fragment2, fieldMap1, fragmentNames1, tmpListFieldMap1FragmentNames1, fieldMap2, fragmentNames2, tmpListFieldMap2FragmentNames2, fragmentNames2Length, j, fragmentNames1Length, i;
    
        // No need to compare a fragment to itself.
        if fragmentName1 === fragmentName2 {
            return;
        }
        // Memoize so two fragments are not compared for conflicts more than once.
        if this->comparedFragmentPairs->has(fragmentName1, fragmentName2, areMutuallyExclusive) {
            return;
        }
        this->comparedFragmentPairs->add(fragmentName1, fragmentName2, areMutuallyExclusive);
        let fragment1 =  context->getFragment(fragmentName1);
        let fragment2 =  context->getFragment(fragmentName2);
        if !(fragment1) || !(fragment2) {
            return;
        }
        let tmpListFieldMap1FragmentNames1 = this->getReferencedFieldsAndFragmentNames(context, fragment1);
        let fieldMap1 = tmpListFieldMap1FragmentNames1[0];
        let fragmentNames1 = tmpListFieldMap1FragmentNames1[1];
        let tmpListFieldMap2FragmentNames2 = this->getReferencedFieldsAndFragmentNames(context, fragment2);
        let fieldMap2 = tmpListFieldMap2FragmentNames2[0];
        let fragmentNames2 = tmpListFieldMap2FragmentNames2[1];
        // (F) First, collect all conflicts between these two collections of fields
        // (not including any nested fragments).
        this->collectConflictsBetween(context, conflicts, areMutuallyExclusive, fieldMap1, fieldMap2);
        // (G) Then collect conflicts between the first fragment and any nested
        // fragments spread in the second fragment.
        let fragmentNames2Length =  count(fragmentNames2);
        let j = 0;
        for j in range(0, fragmentNames2Length) {
            this->collectConflictsBetweenFragments(context, conflicts, areMutuallyExclusive, fragmentName1, fragmentNames2[j]);
        }
        // (G) Then collect conflicts between the second fragment and any nested
        // fragments spread in the first fragment.
        let fragmentNames1Length =  count(fragmentNames1);
        let i = 0;
        for i in range(0, fragmentNames1Length) {
            this->collectConflictsBetweenFragments(context, conflicts, areMutuallyExclusive, fragmentNames1[i], fragmentName2);
        }
    }
    
    /**
     * Find all conflicts found between two selection sets, including those found
     * via spreading in fragments. Called when determining if conflicts exist
     * between the sub-fields of two overlapping fields.
     *
     * @param ValidationContext $context
     * @param bool $areMutuallyExclusive
     * @param CompositeType $parentType1
     * @param $selectionSet1
     * @param CompositeType $parentType2
     * @param $selectionSet2
     * @return array
     */
    protected function findConflictsBetweenSubSelectionSets(<ValidationContext> context, bool areMutuallyExclusive, <CompositeType> parentType1, <SelectionSetNode> selectionSet1, <CompositeType> parentType2, <SelectionSetNode> selectionSet2) -> array
    {
        var conflicts, fieldMap1, fragmentNames1, tmpListFieldMap1FragmentNames1, fieldMap2, fragmentNames2, tmpListFieldMap2FragmentNames2, fragmentNames2Length, comparedFragments, j, fragmentNames1Length, i;
    
        let conflicts =  [];
        let tmpListFieldMap1FragmentNames1 = this->getFieldsAndFragmentNames(context, parentType1, selectionSet1);
        let fieldMap1 = tmpListFieldMap1FragmentNames1[0];
        let fragmentNames1 = tmpListFieldMap1FragmentNames1[1];
        let tmpListFieldMap2FragmentNames2 = this->getFieldsAndFragmentNames(context, parentType2, selectionSet2);
        let fieldMap2 = tmpListFieldMap2FragmentNames2[0];
        let fragmentNames2 = tmpListFieldMap2FragmentNames2[1];
        // (H) First, collect all conflicts between these two collections of field.
        this->collectConflictsBetween(context, conflicts, areMutuallyExclusive, fieldMap1, fieldMap2);
        // (I) Then collect conflicts between the first collection of fields and
        // those referenced by each fragment name associated with the second.
        let fragmentNames2Length =  count(fragmentNames2);
        if fragmentNames2Length !== 0 {
            let comparedFragments =  [];
            let j = 0;
            for j in range(0, fragmentNames2Length) {
                this->collectConflictsBetweenFieldsAndFragment(context, conflicts, comparedFragments, areMutuallyExclusive, fieldMap1, fragmentNames2[j]);
            }
        }
        // (I) Then collect conflicts between the second collection of fields and
        // those referenced by each fragment name associated with the first.
        let fragmentNames1Length =  count(fragmentNames1);
        if fragmentNames1Length !== 0 {
            let comparedFragments =  [];
            let i = 0;
            for i in range(0, fragmentNames2Length) {
                this->collectConflictsBetweenFieldsAndFragment(context, conflicts, comparedFragments, areMutuallyExclusive, fieldMap2, fragmentNames1[i]);
            }
        }
        // (J) Also collect conflicts between any fragment names by the first and
        // fragment names by the second. This compares each item in the first set of
        // names to each item in the second set of names.
        let i = 0;
        for i in range(0, fragmentNames1Length) {
            let j = 0;
            for j in range(0, fragmentNames2Length) {
                this->collectConflictsBetweenFragments(context, conflicts, areMutuallyExclusive, fragmentNames1[i], fragmentNames2[j]);
            }
        }
        return conflicts;
    }
    
    /**
     * Collect all Conflicts "within" one collection of fields.
     *
     * @param ValidationContext $context
     * @param array $conflicts
     * @param array $fieldMap
     */
    protected function collectConflictsWithin(<ValidationContext> context, array conflicts, array fieldMap) -> void
    {
        var responseName, fields, fieldsLength, i, j, conflict;
    
        // A field map is a keyed collection, where each key represents a response
        // name and the value at that key is a list of all fields which provide that
        // response name. For every response name, if there are multiple fields, they
        // must be compared to find a potential conflict.
        for responseName, fields in fieldMap {
            // This compares every field in the list to every other field in this list
            // (except to itself). If the list only has one item, nothing needs to
            // be compared.
            let fieldsLength =  count(fields);
            if fieldsLength > 1 {
                let i = 0;
                for i in range(0, fieldsLength) {
                    let j =  i + 1;
                    for j in range(i + 1, fieldsLength) {
                        let conflict =  this->findConflict(context, false, responseName, fields[i], fields[j]);
                        if conflict {
                            let conflicts[] = conflict;
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Collect all Conflicts between two collections of fields. This is similar to,
     * but different from the `collectConflictsWithin` function above. This check
     * assumes that `collectConflictsWithin` has already been called on each
     * provided collection of fields. This is true because this validator traverses
     * each individual selection set.
     *
     * @param ValidationContext $context
     * @param array $conflicts
     * @param bool $parentFieldsAreMutuallyExclusive
     * @param array $fieldMap1
     * @param array $fieldMap2
     */
    protected function collectConflictsBetween(<ValidationContext> context, array conflicts, bool parentFieldsAreMutuallyExclusive, array fieldMap1, array fieldMap2) -> void
    {
        var responseName, fields1, fields2, fields1Length, fields2Length, i, j, conflict;
    
        // A field map is a keyed collection, where each key represents a response
        // name and the value at that key is a list of all fields which provide that
        // response name. For any response name which appears in both provided field
        // maps, each field from the first field map must be compared to every field
        // in the second field map to find potential conflicts.
        for responseName, fields1 in fieldMap1 {
            if isset fieldMap2[responseName] {
                let fields2 = fieldMap2[responseName];
                let fields1Length =  count(fields1);
                let fields2Length =  count(fields2);
                let i = 0;
                for i in range(0, fields1Length) {
                    let j = 0;
                    for j in range(0, fields2Length) {
                        let conflict =  this->findConflict(context, parentFieldsAreMutuallyExclusive, responseName, fields1[i], fields2[j]);
                        if conflict {
                            let conflicts[] = conflict;
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Determines if there is a conflict between two particular fields, including
     * comparing their sub-fields.
     *
     * @param ValidationContext $context
     * @param bool $parentFieldsAreMutuallyExclusive
     * @param string $responseName
     * @param array $field1
     * @param array $field2
     * @return array|null
     */
    protected function findConflict(<ValidationContext> context, bool parentFieldsAreMutuallyExclusive, string responseName, array field1, array field2)
    {
        var parentType1, ast1, def1, tmpListParentType1Ast1Def1, parentType2, ast2, def2, tmpListParentType2Ast2Def2, areMutuallyExclusive, type1, type2, name1, name2, tmpArray4e4f0dec62c3f50e98f3616e28951ba5, tmpArray40cd750bba9870f18aada2478b24840a, tmpArray8785ed6d39e29d6e59422d3f37734e61, tmpArray762e37652b19e21fb84cef1bd6f06327, selectionSet1, selectionSet2, conflicts;
    
        let tmpListParentType1Ast1Def1 = field1;
        let parentType1 = tmpListParentType1Ast1Def1[0];
        let ast1 = tmpListParentType1Ast1Def1[1];
        let def1 = tmpListParentType1Ast1Def1[2];
        let tmpListParentType2Ast2Def2 = field2;
        let parentType2 = tmpListParentType2Ast2Def2[0];
        let ast2 = tmpListParentType2Ast2Def2[1];
        let def2 = tmpListParentType2Ast2Def2[2];
        // If it is known that two fields could not possibly apply at the same
        // time, due to the parent types, then it is safe to permit them to diverge
        // in aliased field or arguments used as they will not present any ambiguity
        // by differing.
        // It is known that two parent types could never overlap if they are
        // different Object types. Interface or Union types might overlap - if not
        // in the current state of the schema, then perhaps in some future version,
        // thus may not safely diverge.
        let areMutuallyExclusive =  parentFieldsAreMutuallyExclusive || parentType1 !== parentType2 && parentType1 instanceof ObjectType && parentType2 instanceof ObjectType;
        // The return type for each field.
        let type1 =  def1 ? def1->getType()  : null;
        let type2 =  def2 ? def2->getType()  : null;
        if !(areMutuallyExclusive) {
            // Two aliases must refer to the same field.
            let name1 =  ast1->name->value;
            let name2 =  ast2->name->value;
            if name1 !== name2 {
                let tmpArray4e4f0dec62c3f50e98f3616e28951ba5 = [[responseName, "{name1} and {name2} are different fields"], [ast1], [ast2]];
                return tmpArray4e4f0dec62c3f50e98f3616e28951ba5;
            }
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            if !(this->sameArguments( ast1->arguments ? ast1->arguments : tmpArray40cd750bba9870f18aada2478b24840a,  ast2->arguments ? ast2->arguments : tmpArray40cd750bba9870f18aada2478b24840a)) {
                let tmpArray8785ed6d39e29d6e59422d3f37734e61 = [[responseName, "they have differing arguments"], [ast1], [ast2]];
                return tmpArray8785ed6d39e29d6e59422d3f37734e61;
            }
        }
        if type1 && type2 && this->doTypesConflict(type1, type2) {
            let tmpArray762e37652b19e21fb84cef1bd6f06327 = [[responseName, "they return conflicting types {type1} and {type2}"], [ast1], [ast2]];
            return tmpArray762e37652b19e21fb84cef1bd6f06327;
        }
        // Collect and compare sub-fields. Use the same "visited fragment names" list
        // for both collections so fields in a fragment reference are never
        // compared to themselves.
        let selectionSet1 =  ast1->selectionSet;
        let selectionSet2 =  ast2->selectionSet;
        if selectionSet1 && selectionSet2 {
            let conflicts =  this->findConflictsBetweenSubSelectionSets(context, areMutuallyExclusive, Type::getNamedType(type1), selectionSet1, Type::getNamedType(type2), selectionSet2);
            return this->subfieldConflicts(conflicts, responseName, ast1, ast2);
        }
        return null;
    }
    
    /**
     * @param ArgumentNode[] $arguments1
     * @param ArgumentNode[] $arguments2
     *
     * @return bool
     */
    protected function sameArguments(array arguments1, array arguments2) -> bool
    {
        var argument1, argument2, argument;
    
        if count(arguments1) !== count(arguments2) {
            return false;
        }
        for argument1 in arguments1 {
            let argument2 =  null;
            for argument in arguments2 {
                if argument->name->value === argument1->name->value {
                    let argument2 = argument;
                    break;
                }
            }
            if !(argument2) {
                return false;
            }
            if !(this->sameValue(argument1->value, argument2->value)) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * @param Node $value1
     * @param Node $value2
     * @return bool
     */
    protected function sameValue(<Node> value1, <Node> value2) -> bool
    {
        return !(value1) && !(value2) || Printer::doPrint(value1) === Printer::doPrint(value2);
    }
    
    /**
     * Two types conflict if both types could not apply to a value simultaneously.
     * Composite types are ignored as their individual field types will be compared
     * later recursively. However List and Non-Null types must match.
     *
     * @param OutputType $type1
     * @param OutputType $type2
     * @return bool
     */
    protected function doTypesConflict(<OutputType> type1, <OutputType> type2) -> bool
    {
        if type1 instanceof ListOfType {
            return  type2 instanceof ListOfType ? this->doTypesConflict(type1->getWrappedType(), type2->getWrappedType())  : true;
        }
        if type2 instanceof ListOfType {
            return  type1 instanceof ListOfType ? this->doTypesConflict(type1->getWrappedType(), type2->getWrappedType())  : true;
        }
        if type1 instanceof NonNull {
            return  type2 instanceof NonNull ? this->doTypesConflict(type1->getWrappedType(), type2->getWrappedType())  : true;
        }
        if type2 instanceof NonNull {
            return  type1 instanceof NonNull ? this->doTypesConflict(type1->getWrappedType(), type2->getWrappedType())  : true;
        }
        if Type::isLeafType(type1) || Type::isLeafType(type2) {
            return type1 !== type2;
        }
        return false;
    }
    
    /**
     * Given a selection set, return the collection of fields (a mapping of response
     * name to field ASTs and definitions) as well as a list of fragment names
     * referenced via fragment spreads.
     *
     * @param ValidationContext $context
     * @param CompositeType $parentType
     * @param SelectionSetNode $selectionSet
     * @return array
     */
    protected function getFieldsAndFragmentNames(<ValidationContext> context, <CompositeType> parentType, <SelectionSetNode> selectionSet) -> array
    {
        var astAndDefs, fragmentNames, cached;
    
        if !(isset this->cachedFieldsAndFragmentNames[selectionSet]) {
            let astAndDefs =  [];
            let fragmentNames =  [];
            this->internalCollectFieldsAndFragmentNames(context, parentType, selectionSet, astAndDefs, fragmentNames);
            let cached =  [astAndDefs, array_keys(fragmentNames)];
            let this->cachedFieldsAndFragmentNames[selectionSet] = cached;
        } else {
            let cached = this->cachedFieldsAndFragmentNames[selectionSet];
        }
        return cached;
    }
    
    /**
     * Given a reference to a fragment, return the represented collection of fields
     * as well as a list of nested fragment names referenced via fragment spreads.
     *
     * @param ValidationContext $context
     * @param FragmentDefinitionNode $fragment
     * @return array|object
     */
    protected function getReferencedFieldsAndFragmentNames(<ValidationContext> context, <FragmentDefinitionNode> fragment)
    {
        var fragmentType;
    
        // Short-circuit building a type from the AST if possible.
        if isset this->cachedFieldsAndFragmentNames[fragment->selectionSet] {
            return this->cachedFieldsAndFragmentNames[fragment->selectionSet];
        }
        let fragmentType =  TypeInfo::typeFromAST(context->getSchema(), fragment->typeCondition);
        return this->getFieldsAndFragmentNames(context, fragmentType, fragment->selectionSet);
    }
    
    /**
     * Given a reference to a fragment, return the represented collection of fields
     * as well as a list of nested fragment names referenced via fragment spreads.
     *
     * @param ValidationContext $context
     * @param CompositeType $parentType
     * @param SelectionSetNode $selectionSet
     * @param array $astAndDefs
     * @param array $fragmentNames
     */
    protected function internalCollectFieldsAndFragmentNames(<ValidationContext> context, <CompositeType> parentType, <SelectionSetNode> selectionSet, array astAndDefs, array fragmentNames) -> void
    {
        var selectionSetLength, i, selection, fieldName, fieldDef, tmp, responseName, typeCondition, inlineFragmentType;
    
        let selectionSetLength =  count(selectionSet->selections);
        let i = 0;
        for i in range(0, selectionSetLength) {
            let selection = selectionSet->selections[i];
            if selection instanceof FieldNode {
                let fieldName =  selection->name->value;
                let fieldDef =  null;
                if parentType instanceof ObjectType || parentType instanceof InterfaceType {
                    let tmp =  parentType->getFields();
                    if isset tmp[fieldName] {
                        let fieldDef = tmp[fieldName];
                    }
                }
                let responseName =  selection->alias ? selection->alias->value  : fieldName;
                if !(isset astAndDefs[responseName]) {
                    let astAndDefs[responseName] =  [];
                }
                let astAndDefs[responseName][] =  [parentType, selection, fieldDef];
            } elseif selection instanceof FragmentSpreadNode {
                let fragmentNames[selection->name->value] = true;
            } else {
                let typeCondition =  selection->typeCondition;
                let inlineFragmentType =  typeCondition ? TypeInfo::typeFromAST(context->getSchema(), typeCondition)  : parentType;
                this->internalcollectFieldsAndFragmentNames(context, inlineFragmentType, selection->selectionSet, astAndDefs, fragmentNames);
            }
        }
    }
    
    /**
     * Given a series of Conflicts which occurred between two sub-fields, generate
     * a single Conflict.
     *
     * @param array $conflicts
     * @param string $responseName
     * @param FieldNode $ast1
     * @param FieldNode $ast2
     * @return array|null
     */
    protected function subfieldConflicts(array conflicts, string responseName, <FieldNode> ast1, <FieldNode> ast2)
    {
        var tmpArray1050a401641a3a026503504547611dcf, tmpArrayf872d317de38d14eda9e83dcf0f89ae1, tmpArrayc58f27db226780d4220b692d641987dd;
    
        if count(conflicts) > 0 {
            let tmpArray1050a401641a3a026503504547611dcf = [[responseName, array_map(new OverlappingFieldsCanBeMergedsubfieldConflictsClosureOne(), conflicts)], array_reduce(conflicts, new OverlappingFieldsCanBeMergedsubfieldConflictsClosureOne(), tmpArrayf872d317de38d14eda9e83dcf0f89ae1), array_reduce(conflicts, new OverlappingFieldsCanBeMergedsubfieldConflictsClosureOne(), tmpArrayc58f27db226780d4220b692d641987dd)];
            return tmpArrayd907c30f5c17ae50fb464fd39e34f85e;
        }
    }

}