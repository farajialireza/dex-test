const Dex = artifacts.require('Dex')
const Link = artifacts.require('Link')
const truffleAssert = require("truffle-assertions")

// THE USER MUST HAVE ETH DEPOSITED SUCH THAT DEPOSITED ETH >= BUY ORDER VALUE
contract('Dex', accounts => {
    it('should throw an error if ETH balance is too low when creating BUY limit order', async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await truffleAssert.reverts(
            dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        dex.depositEth({ value: 10 })
        await truffleAssert.passes(
            dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
        )
    })

    // THE USER MUST HAVE ENOUGH TOKEN DEPOSITED SUCH THAT TOKEN BALANCE >= SELL ORDER AMOUNT
    it('should throw an error if ETH balance is too low when creating SELL limit order', async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await truffleAssert.reverts(
            dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )

        await link.approve(dex.address, 500)
        await dex.addToken(web3.utils.fromUtf8("LINK"), link.address, { from: accounts[0] })
        await dex.deposit(10, web3.utils.fromUtf8("LINK"))
        await truffleAssert.passes(
            dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
    })

    // THE FIRST ORDER ([0]) IN THE BUY ORDER BOOK SHOULD HAVE THE HIGHEST PRICE, SORTED HIGHEST TO LOWEST STARTING AT INDEX 0
    it('The BUY order book should be ordered on price from highest to lowest starting at index 0', async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await link.approve(dex.address, 500)
        dex.depositEth({ value: 3000 })
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 300)
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 100)
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 200)

        let oredrbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0)
        console.log(oredrbook)
        for (let i = 0; i < oredrbook.length - 1; i++) {
            assert(oredrbook[i].price > oredrbook[i+1].price, 'not right order in buy book')
        }
    })

    // The SELL ORDER MUST BE SORTED FROM LOWEST TO HIGHEST STARTING AT INDEX 0
    it('The BUY order book should be ordered on price from highest to lowest starting at index 0', async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await link.approve(dex.address, 500)
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 300)
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 100)
        dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 200)

        let oredrbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1)
        console.log(oredrbook)
        for (let i = 0; i < oredrbook.length - 1; i++) {
            assert(oredrbook[i].price <= oredrbook[i+1].price, 'not right order in sell book')
        }
    })
})