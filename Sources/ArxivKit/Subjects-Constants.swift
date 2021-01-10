
/// A namespace for Subject constants.
public enum ArxivSubjects {}

public extension ArxivSubjects {
    
    /// Returns a `SubjectTree` that can be used to recursively enumerate all available subjects
    /// and their groupings as organised on [arXiv.org](https://arxiv.org).
   static var all = SubjectTree.grouping(
        name: "\(ArxivSubject("main").name)",
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

extension ArxivSubjects {
        
    static var nonArXiveSubjects = ["main", "physics-field"]
    
    static var main = ArxivSubject("main")
    
    static var allPhysics = ArxivSubject("physics-field")
}


private extension ArxivSubjects {
    
    static var physicsGroup = SubjectTree.grouping(
        name: "Physics Subjects",
        children: ArxivSubject("physics-field").children.map { .subject($0) }
    )
    
    static var nonPhysicsRootSubjects: [ArxivSubject] {
        return main.children.filter { $0.symbol != allPhysics.symbol }
    }
}

public extension ArxivSubjects.OtherPhysicsSubjects {

    static let generalRelativityAndQuantumCosmology = ArxivSubject("gr-qc")

    static let highEnergyPhysicsExperiment = ArxivSubject("hep-ex")

    static let highEnergyPhysicsLattice = ArxivSubject("hep-lat")

    static let highEnergyPhysicsPhenomenology = ArxivSubject("hep-ph")

    static let highEnergyPhysicsTheory = ArxivSubject("hep-th")

    static let mathematicalPhysics = ArxivSubject("math-ph")

    static let nuclearExperiment = ArxivSubject("nucl-ex")

    static let nuclearTheory = ArxivSubject("nucl-th")

    static let quantumPhysics = ArxivSubject("quant-ph")
}

public extension ArxivSubjects.Mathematics {

    static let all = ArxivSubject("math.*")

    static let algebraicGeometry = ArxivSubject("math.AG")

    static let algebraicTopology = ArxivSubject("math.AT")

    static let analysisOfPdes = ArxivSubject("math.AP")

    static let categoryTheory = ArxivSubject("math.CT")

    static let classicalAnalysisAndOdes = ArxivSubject("math.CA")

    static let combinatorics = ArxivSubject("math.CO")

    static let comutativeAlgebra = ArxivSubject("math.AC")

    static let complexVariables = ArxivSubject("math.CV")

    static let differentialGeometry = ArxivSubject("math.DG")

    static let dynamicalSystems = ArxivSubject("math.DS")

    static let functionalAnalysis = ArxivSubject("math.FA")

    static let generalMathematics = ArxivSubject("math.GM")

    static let generalTopology = ArxivSubject("math.GN")

    static let geometricTopology = ArxivSubject("math.GT")

    static let groupTheory = ArxivSubject("math.GR")

    static let historyAndOverview = ArxivSubject("math.HO")

    static let informationTheory = ArxivSubject("math.IT")

    static let kTheoryAndHomology = ArxivSubject("math.KT")

    static let logic = ArxivSubject("math.LO")

    static let mathematicalPhysics = ArxivSubject("math.MP")

    static let metricGeometry = ArxivSubject("math.MG")

    static let numberTheory = ArxivSubject("math.NT")

    static let numericalAnalysis = ArxivSubject("math.NA")

    static let operatorAlgebras = ArxivSubject("math.OA")

    static let optimizationAndControl = ArxivSubject("math.OC")

    static let probability = ArxivSubject("math.PR")

    static let quantumAlgebra = ArxivSubject("math.QA")

    static let representationTheory = ArxivSubject("math.RT")

    static let ringsAndAlgebras = ArxivSubject("math.RA")

    static let spectralTheory = ArxivSubject("math.SP")

    static let statisticsTheory = ArxivSubject("math.ST")

    static let symplecticGeometry = ArxivSubject("math.SG")
}

public extension ArxivSubjects.QuantitativeBiology {

    static let all = ArxivSubject("q-bio.*")

    static let biomolecules = ArxivSubject("q-bio.BM")

    static let cellBehavior = ArxivSubject("q-bio.CB")

    static let genomics = ArxivSubject("q-bio.GN")

    static let molecularNetworks = ArxivSubject("q-bio.MN")

    static let neuronsAndCognition = ArxivSubject("q-bio.NC")

    static let otherQuantitativeBiology = ArxivSubject("q-bio.OT")

    static let populationsAndEvolution = ArxivSubject("q-bio.PE")

    static let quantitativeMethods = ArxivSubject("q-bio.QM")

    static let subcellularProcesses = ArxivSubject("q-bio.SC")

    static let tissuesAndOrgans = ArxivSubject("q-bio.TO")
}

public extension ArxivSubjects.ComputerScience {

    static let all = ArxivSubject("cs.*")

    static let artificialIntelligence = ArxivSubject("cs.AI")

    static let computationAndLanguage = ArxivSubject("cs.CL")

    static let computationalComplexity = ArxivSubject("cs.CC")

    static let computationalEngineeringFinanceAndScience = ArxivSubject("cs.CE")

    static let computationalGeometry = ArxivSubject("cs.CG")

    static let computerScienceAndGameTheory = ArxivSubject("cs.GT")

    static let computerVisionAndPatternRecognition = ArxivSubject("cs.CV")

    static let computersAndSociety = ArxivSubject("cs.CY")

    static let cryptographyAndSecurity = ArxivSubject("cs.CR")

    static let dataStructuresAndAlgorithms = ArxivSubject("cs.DS")

    static let databases = ArxivSubject("cs.DB")

    static let digitalLibraries = ArxivSubject("cs.DL")

    static let discreteMathematics = ArxivSubject("cs.DM")

    static let distributedParallelAndClusterComputing = ArxivSubject("cs.DC")

    static let emergingTechnologies = ArxivSubject("cs.ET")

    static let formalLanguagesAndAutomataTheory = ArxivSubject("cs.FL")

    static let generalLiterature = ArxivSubject("cs.GL")

    static let graphics = ArxivSubject("cs.GR")

    static let hardwareArchitecture = ArxivSubject("cs.AR")

    static let humanComputerInteraction = ArxivSubject("cs.HC")

    static let informationRetrieval = ArxivSubject("cs.IR")

    static let informationTheory = ArxivSubject("cs.IT")

    static let learning = ArxivSubject("cs.LG")

    static let logicInComputerScience = ArxivSubject("cs.LO")

    static let mathematicalSoftware = ArxivSubject("cs.MS")

    static let multiagentSystems = ArxivSubject("cs.MA")

    static let multimedia = ArxivSubject("cs.MM")

    static let networkingAndInternetArchitecture = ArxivSubject("cs.NI")

    static let neuralAndEvolutionaryComputing = ArxivSubject("cs.NE")

    static let numericalAnalysis = ArxivSubject("cs.NA")

    static let operatingSystems = ArxivSubject("cs.OS")

    static let otherComputerScience = ArxivSubject("cs.OH")

    static let performance = ArxivSubject("cs.PF")

    static let programmingLanguages = ArxivSubject("cs.PL")

    static let robotics = ArxivSubject("cs.RO")

    static let socialAndInformationNetworks = ArxivSubject("cs.SI")

    static let softwareEngineering = ArxivSubject("cs.SE")

    static let sound = ArxivSubject("cs.SD")

    static let symbolicComputation = ArxivSubject("cs.SC")

    static let systemsAndControl = ArxivSubject("cs.SY")
}

public extension ArxivSubjects.QuantitativeFinance {

    static let all = ArxivSubject("q-fin.*")

    static let computationalFinance = ArxivSubject("q-fin.CP")

    static let economics = ArxivSubject("q-fin.EC")

    static let generalFinance = ArxivSubject("q-fin.GN")

    static let mathematicalFinance = ArxivSubject("q-fin.MF")

    static let portfolioManagement = ArxivSubject("q-fin.PM")

    static let pricingOfSecurities = ArxivSubject("q-fin.PR")

    static let riskManagement = ArxivSubject("q-fin.RM")

    static let statisticalFinance = ArxivSubject("q-fin.ST")

    static let tradingAndMarketMicrostructure = ArxivSubject("q-fin.TR")
}

public extension ArxivSubjects.ElectricalEngineeringAndSystemsScience {

    static let all = ArxivSubject("eess.*")

    static let audioAndSpeechProcessing = ArxivSubject("eess.AS")

    static let imageAndVideoProcessing = ArxivSubject("eess.IV")

    static let signalProcessing = ArxivSubject("eess.SP")

    static let systemsAndControl = ArxivSubject("eess.SY")
}

public extension ArxivSubjects.Statistics {

    static let all = ArxivSubject("stat.*")

    static let applications = ArxivSubject("stat.AP")

    static let computation = ArxivSubject("stat.CO")

    static let machineLearning = ArxivSubject("stat.ML")

    static let methodology = ArxivSubject("stat.ME")

    static let otherStatistics = ArxivSubject("stat.OT")

    static let statisticsTheory = ArxivSubject("stat.TH")
}

public extension ArxivSubjects.Physics {

    static let all = ArxivSubject("physics.*")

    static let acceleratorPhysics = ArxivSubject("physics.acc-ph")

    static let atmosphericAndOceanicPhysics = ArxivSubject("physics.ao-ph")

    static let atomicPhysics = ArxivSubject("physics.atom-ph")

    static let atomicAndMolecularClusters = ArxivSubject("physics.atm-clus")

    static let biologicalPhysics = ArxivSubject("physics.bio-ph")

    static let chemicalPhysics = ArxivSubject("physics.chem-ph")

    static let classicalPhysics = ArxivSubject("physics.class-ph")

    static let computationalPhysics = ArxivSubject("physics.comp-ph")

    static let dataAnalysisStatisticsAndProbability = ArxivSubject("physics.data-an")

    static let fluidDynamics = ArxivSubject("physics.flu-dyn")

    static let generalPhysics = ArxivSubject("physics.gen-ph")

    static let geophysics = ArxivSubject("physics.geo-ph")

    static let historyAndPhilosophyOfPhysics = ArxivSubject("physics.hist-ph")

    static let instrumentationAndDetectors = ArxivSubject("physics.ins-det")

    static let medicalPhysics = ArxivSubject("physics.med-ph")

    static let optics = ArxivSubject("physics.optics")

    static let physicsEducation = ArxivSubject("physics.ed-ph")

    static let physicsAndSociety = ArxivSubject("physics.soc-ph")

    static let plasmaPhysics = ArxivSubject("physics.plasm-ph")

    static let popularPhysics = ArxivSubject("physics.pop-ph")

    static let spacePhysics = ArxivSubject("physics.space-ph")
}

public extension ArxivSubjects.CondensedMatter {

    static let all = ArxivSubject("cond-mat.*")

    static let disorderedSystemsAndNeuralNetworks = ArxivSubject("cond-mat.dis-nn")

    static let materialsScience = ArxivSubject("cond-mat.mtrl-sci")

    static let mesoscaleAndNanoscalePhysics = ArxivSubject("cond-mat.mes-hall")

    static let otherCondensedMatter = ArxivSubject("cond-mat.other")

    static let quantumGases = ArxivSubject("cond-mat.quant-gas")

    static let softCondensedMatter = ArxivSubject("cond-mat.soft")

    static let statisticalMechanics = ArxivSubject("cond-mat.stat-mech")

    static let stronglyCorrelatedElectrons = ArxivSubject("cond-mat.str-el")

    static let superconductivity = ArxivSubject("cond-mat.supr-con")
}

public extension ArxivSubjects.NonlinearSciences {

    static let all = ArxivSubject("nlin.*")


    static let adaptationAndSelfOrganizingSystems = ArxivSubject("nlin.AO")

    static let cellularAutomataAndLatticeGases = ArxivSubject("nlin.CG")

    static let chaoticDynamics = ArxivSubject("nlin.CD")

    static let exactlySolvableAndIntegrableSystems = ArxivSubject("nlin.SI")

    static let patternFormationAndSolitons = ArxivSubject("nlin.PS")
}

public extension ArxivSubjects.Economy {

    static let all = ArxivSubject("econ.*")

    static let econometrics = ArxivSubject("econ.EM")

    static let generalEconomics = ArxivSubject("econ.GN")

    static let theoreticalEconomics = ArxivSubject("econ.TH")
}

public extension ArxivSubjects.Astrophysics {

    static let all = ArxivSubject("astro-ph.*")

    static let cosmologyAndNongalacticAstrophysics = ArxivSubject("astro-ph.CO")

    static let earthAndPlanetaryAstrophysics = ArxivSubject("astro-ph.EP")

    static let astrophysicsOfGalaxies = ArxivSubject("astro-ph.GA")

    static let highEnergyAstrophysicalPhenomena = ArxivSubject("astro-ph.HE")

    static let instrumentationAndMethodsForAstrophysics = ArxivSubject("astro-ph.IM")

    static let solarAndStellarAstrophysics = ArxivSubject("astro-ph.SR")
}

