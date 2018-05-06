namespace GraphQL\Executor\Promise\Adapter;

class ReactPromiseAdapterallClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(item)
    {
    return  item instanceof Promise ? item->adoptedPromise  : item;
    }
}
    