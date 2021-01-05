
/// A namespace for Subject constants.
public enum Subjects {}

public extension Subjects {
    
   static var all = SubjectTree.grouping(
        name: "\(Subject("main").name)",
        children: [physicsGroup] + nonPhysicsRootSubjects.map { .subject($0) }
    )
    
    enum OtherPhysicsSubjects {}

    enum CondensedMatter {}

    enum Economy {}

    enum Statistics {}

    enum ComputerScience {}

    enum Astrophysics {}

    enum ElectricalEngineeringAndSystemsScience {}

    enum QuantitativeBiology {}

    enum Mathematics {}

    enum QuantitativeFinance {}

    enum Physics {}

    enum NonlinearSciences {}
}

extension Subjects {
        
    /// Internal root subject.
    static var main = Subject("main")
    
    /// Internal physics group subject.
    static var allPhysics = Subject("physics-field")
}


private extension Subjects {
    
    static var physicsGroup = SubjectTree.grouping(
        name: "Physics Subjects",
        children: Subject("physics-field").children.map { .subject($0) }
    )
    
    static var nonPhysicsRootSubjects: [Subject] {
        return main.children.filter { $0.symbol != allPhysics.symbol }
    }
}

public extension Subjects.OtherPhysicsSubjects {

    static let generalRelativityAndQuantumCosmology = Subject("gr-qc")

    static let highEnergyPhysicsExperiment = Subject("hep-ex")

    static let highEnergyPhysicsLattice = Subject("hep-lat")

    static let highEnergyPhysicsPhenomenology = Subject("hep-ph")

    static let highEnergyPhysicsTheory = Subject("hep-th")

    static let mathematicalPhysics = Subject("math-ph")

    static let nuclearExperiment = Subject("nucl-ex")

    static let nuclearTheory = Subject("nucl-th")

    static let quantumPhysics = Subject("quant-ph")
}

public extension Subjects.Mathematics {

    static let all = Subject("math.*")

    static let algebraicGeometry = Subject("math.AG")

    static let algebraicTopology = Subject("math.AT")

    static let analysisOfPdes = Subject("math.AP")

    static let categoryTheory = Subject("math.CT")

    static let classicalAnalysisAndOdes = Subject("math.CA")

    static let combinatorics = Subject("math.CO")

    static let comutativeAlgebra = Subject("math.AC")

    static let complexVariables = Subject("math.CV")

    static let differentialGeometry = Subject("math.DG")

    static let dynamicalSystems = Subject("math.DS")

    static let functionalAnalysis = Subject("math.FA")

    static let generalMathematics = Subject("math.GM")

    static let generalTopology = Subject("math.GN")

    static let geometricTopology = Subject("math.GT")

    static let groupTheory = Subject("math.GR")

    static let historyAndOverview = Subject("math.HO")

    static let informationTheory = Subject("math.IT")

    static let kTheoryAndHomology = Subject("math.KT")

    static let logic = Subject("math.LO")

    static let mathematicalPhysics = Subject("math.MP")

    static let metricGeometry = Subject("math.MG")

    static let numberTheory = Subject("math.NT")

    static let numericalAnalysis = Subject("math.NA")

    static let operatorAlgebras = Subject("math.OA")

    static let optimizationAndControl = Subject("math.OC")

    static let probability = Subject("math.PR")

    static let quantumAlgebra = Subject("math.QA")

    static let representationTheory = Subject("math.RT")

    static let ringsAndAlgebras = Subject("math.RA")

    static let spectralTheory = Subject("math.SP")

    static let statisticsTheory = Subject("math.ST")

    static let symplecticGeometry = Subject("math.SG")
}

public extension Subjects.QuantitativeBiology {

    static let all = Subject("q-bio.*")

    static let biomolecules = Subject("q-bio.BM")

    static let cellBehavior = Subject("q-bio.CB")

    static let genomics = Subject("q-bio.GN")

    static let molecularNetworks = Subject("q-bio.MN")

    static let neuronsAndCognition = Subject("q-bio.NC")

    static let otherQuantitativeBiology = Subject("q-bio.OT")

    static let populationsAndEvolution = Subject("q-bio.PE")

    static let quantitativeMethods = Subject("q-bio.QM")

    static let subcellularProcesses = Subject("q-bio.SC")

    static let tissuesAndOrgans = Subject("q-bio.TO")
}

public extension Subjects.ComputerScience {

    static let all = Subject("cs.*")

    static let artificialIntelligence = Subject("cs.AI")

    static let computationAndLanguage = Subject("cs.CL")

    static let computationalComplexity = Subject("cs.CC")

    static let computationalEngineeringFinanceAndScience = Subject("cs.CE")

    static let computationalGeometry = Subject("cs.CG")

    static let computerScienceAndGameTheory = Subject("cs.GT")

    static let computerVisionAndPatternRecognition = Subject("cs.CV")

    static let computersAndSociety = Subject("cs.CY")

    static let cryptographyAndSecurity = Subject("cs.CR")

    static let dataStructuresAndAlgorithms = Subject("cs.DS")

    static let databases = Subject("cs.DB")

    static let digitalLibraries = Subject("cs.DL")

    static let discreteMathematics = Subject("cs.DM")

    static let distributedParallelAndClusterComputing = Subject("cs.DC")

    static let emergingTechnologies = Subject("cs.ET")

    static let formalLanguagesAndAutomataTheory = Subject("cs.FL")

    static let generalLiterature = Subject("cs.GL")

    static let graphics = Subject("cs.GR")

    static let hardwareArchitecture = Subject("cs.AR")

    static let humanComputerInteraction = Subject("cs.HC")

    static let informationRetrieval = Subject("cs.IR")

    static let informationTheory = Subject("cs.IT")

    static let learning = Subject("cs.LG")

    static let logicInComputerScience = Subject("cs.LO")

    static let mathematicalSoftware = Subject("cs.MS")

    static let multiagentSystems = Subject("cs.MA")

    static let multimedia = Subject("cs.MM")

    static let networkingAndInternetArchitecture = Subject("cs.NI")

    static let neuralAndEvolutionaryComputing = Subject("cs.NE")

    static let numericalAnalysis = Subject("cs.NA")

    static let operatingSystems = Subject("cs.OS")

    static let otherComputerScience = Subject("cs.OH")

    static let performance = Subject("cs.PF")

    static let programmingLanguages = Subject("cs.PL")

    static let robotics = Subject("cs.RO")

    static let socialAndInformationNetworks = Subject("cs.SI")

    static let softwareEngineering = Subject("cs.SE")

    static let sound = Subject("cs.SD")

    static let symbolicComputation = Subject("cs.SC")

    static let systemsAndControl = Subject("cs.SY")
}

public extension Subjects.QuantitativeFinance {

    static let all = Subject("q-fin.*")

    static let computationalFinance = Subject("q-fin.CP")

    static let economics = Subject("q-fin.EC")

    static let generalFinance = Subject("q-fin.GN")

    static let mathematicalFinance = Subject("q-fin.MF")

    static let portfolioManagement = Subject("q-fin.PM")

    static let pricingOfSecurities = Subject("q-fin.PR")

    static let riskManagement = Subject("q-fin.RM")

    static let statisticalFinance = Subject("q-fin.ST")

    static let tradingAndMarketMicrostructure = Subject("q-fin.TR")
}

public extension Subjects.ElectricalEngineeringAndSystemsScience {

    static let all = Subject("eess.*")

    static let audioAndSpeechProcessing = Subject("eess.AS")

    static let imageAndVideoProcessing = Subject("eess.IV")

    static let signalProcessing = Subject("eess.SP")

    static let systemsAndControl = Subject("eess.SY")
}

public extension Subjects.Statistics {

    static let all = Subject("stat.*")

    static let applications = Subject("stat.AP")

    static let computation = Subject("stat.CO")

    static let machineLearning = Subject("stat.ML")

    static let methodology = Subject("stat.ME")

    static let otherStatistics = Subject("stat.OT")

    static let statisticsTheory = Subject("stat.TH")
}

public extension Subjects.Physics {

    static let all = Subject("physics.*")

    static let acceleratorPhysics = Subject("physics.acc-ph")

    static let atmosphericAndOceanicPhysics = Subject("physics.ao-ph")

    static let atomicPhysics = Subject("physics.atom-ph")

    static let atomicAndMolecularClusters = Subject("physics.atm-clus")

    static let biologicalPhysics = Subject("physics.bio-ph")

    static let chemicalPhysics = Subject("physics.chem-ph")

    static let classicalPhysics = Subject("physics.class-ph")

    static let computationalPhysics = Subject("physics.comp-ph")

    static let dataAnalysisStatisticsAndProbability = Subject("physics.data-an")

    static let fluidDynamics = Subject("physics.flu-dyn")

    static let generalPhysics = Subject("physics.gen-ph")

    static let geophysics = Subject("physics.geo-ph")

    static let historyAndPhilosophyOfPhysics = Subject("physics.hist-ph")

    static let instrumentationAndDetectors = Subject("physics.ins-det")

    static let medicalPhysics = Subject("physics.med-ph")

    static let optics = Subject("physics.optics")

    static let physicsEducation = Subject("physics.ed-ph")

    static let physicsAndSociety = Subject("physics.soc-ph")

    static let plasmaPhysics = Subject("physics.plasm-ph")

    static let popularPhysics = Subject("physics.pop-ph")

    static let spacePhysics = Subject("physics.space-ph")
}

public extension Subjects.CondensedMatter {

    static let all = Subject("cond-mat.*")

    static let disorderedSystemsAndNeuralNetworks = Subject("cond-mat.dis-nn")

    static let materialsScience = Subject("cond-mat.mtrl-sci")

    static let mesoscaleAndNanoscalePhysics = Subject("cond-mat.mes-hall")

    static let otherCondensedMatter = Subject("cond-mat.other")

    static let quantumGases = Subject("cond-mat.quant-gas")

    static let softCondensedMatter = Subject("cond-mat.soft")

    static let statisticalMechanics = Subject("cond-mat.stat-mech")

    static let stronglyCorrelatedElectrons = Subject("cond-mat.str-el")

    static let superconductivity = Subject("cond-mat.supr-con")
}

public extension Subjects.NonlinearSciences {

    static let all = Subject("nlin.*")


    static let adaptationAndSelfOrganizingSystems = Subject("nlin.AO")

    static let cellularAutomataAndLatticeGases = Subject("nlin.CG")

    static let chaoticDynamics = Subject("nlin.CD")

    static let exactlySolvableAndIntegrableSystems = Subject("nlin.SI")

    static let patternFormationAndSolitons = Subject("nlin.PS")
}

public extension Subjects.Economy {

    static let all = Subject("econ.*")

    static let econometrics = Subject("econ.EM")

    static let generalEconomics = Subject("econ.GN")

    static let theoreticalEconomics = Subject("econ.TH")
}

public extension Subjects.Astrophysics {

    static let all = Subject("astro-ph.*")

    static let cosmologyAndNongalacticAstrophysics = Subject("astro-ph.CO")

    static let earthAndPlanetaryAstrophysics = Subject("astro-ph.EP")

    static let astrophysicsOfGalaxies = Subject("astro-ph.GA")

    static let highEnergyAstrophysicalPhenomena = Subject("astro-ph.HE")

    static let instrumentationAndMethodsForAstrophysics = Subject("astro-ph.IM")

    static let solarAndStellarAstrophysics = Subject("astro-ph.SR")
}

