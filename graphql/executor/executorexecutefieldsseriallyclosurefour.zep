namespace GraphQL\Executor;

class ExecutorexecuteFieldsSeriallyClosureFour
{

    public function __construct()
    {
        
    }

    public function __invoke(results, responseName, path, parentType, sourceValue, fieldNodes)
    {
    let fieldPath = path;
    let fieldPath[] = responseName;
    let result =  this->resolveField(parentType, sourceValue, fieldNodes, fieldPath);
    if result === self::undefined {
        return results;
    }
    let promise =  this->getPromise(result);
    if promise {
        let results[responseName] = resolvedResult;
        return promise->then(new ExecutorsetDefaultResolveFnClosureOne(responseName, results));
    }
    let results[responseName] = result;
    return results;
    }
}
    