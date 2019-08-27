var myQueue = []

function addToQueue(runTask) {
    console.log('Started')
    if (myQueue.length > 0) {
        myQueue.push(runTask);
    }
    else {
        myQueue.push(runTask)
        myQueue[0](onTaskEnd);
    }

}

function onTaskEnd(runTask) {
    console.log('Finished')
    myQueue.shift();

    if (myQueue.length > 0) {
        myQueue[0](onTaskEnd);
    }

}

function abortFromQueue(runTask) {
    myQueue.splice(myQueue.indexOf(runTask), 1)
}