namespace GraphQL\Executor\Promise\Adapter;

class SyncPromiseAdapterallClosureZero
{
    private index;
    private count;
    private total;
    private result;
    private all;

    public function __construct(index, count, total, result, all)
    {
                let this->index = index;
        let this->count = count;
        let this->total = total;
        let this->result = result;
        let this->all = all;

    }

    public function __invoke(value)
    {
    this->result[this->index];
    this->count;
    if this->count >= this->total {
        this->all->resolve(this->result);
    }
    }
}
    