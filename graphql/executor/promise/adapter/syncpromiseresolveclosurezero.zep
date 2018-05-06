namespace GraphQL\Executor\Promise\Adapter;

class SyncPromiseresolveClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(resolvedValue)
    {
    this->resolve(resolvedValue);
    }
}
    