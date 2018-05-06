namespace GraphQL\Executor\Promise\Adapter;

class SyncPromiseresolveClosureOne
{

    public function __construct()
    {
        
    }

    public function __invoke(reason)
    {
    this->reject(reason);
    }
}
    